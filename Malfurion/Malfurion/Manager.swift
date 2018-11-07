//
//  Manager.swift
//  Malfurion
//
//  Created by Shaw on 04/07/2018.
//  Copyright © 2018 Forcewith Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire
import PINCache

enum LoadDataOption {
    case network /// 优先从网络中获取数据
    case cache   /// 优先从缓存中获取数据
}

enum ManagerStatus {
    case noRequest  //没有产生过API请求，这个是manager的默认状态。
    case success    //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    case noContent  //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    case paramError //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    case timeOut    //请求超时。
    case noNetwork  //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
}

open class Manager: ManagerProtocol {
    
    lazy var pinCache: PINCache? = {
        switch self.cache {
        case .noCache:
            return nil
        case .cache(let age):
            let cache = PINCache(name: String(describing: type(of: self)))
            cache.diskCache.ageLimit = age
            cache.memoryCache.ageLimit = age
            return cache
        }
    }()
    
    open var interceptor: Interceptor?
    open var validator: Validator?
    
    open var response: Response?
    
    open var paramSource: ParameterSource?
    open var callBack: CallBack?
    
    open var methondName: String = ""
    open var service: Service? = nil
    open var requestType: HTTPMethod = .post
    open var cache: CacheDataOption = CacheDataOption.noCache
    open var shouldAllowMutiRequest: Bool = true
    open var cacheRefer: String? //可以设置一个缓存相关的字符串，比如用户ID，这样这个服务的缓存Key就会带上用户ID，从而跟ID相关

    var isLoading: Bool = false
    var status: ManagerStatus = .noRequest
    
    var fetchedRawData: Any?
    
    public init() {
        
    }
    
    public func cleanData() {
        
    }
    
    open func fix(with finalParameters: Parameters?) -> Parameters? {
        return finalParameters
    }
    
    //默认优先从缓存中取数据
    public func loadData() -> Void {
        switch self.cache {
        case .noCache:
            loadData(with: self.paramSource?.parameters(of: self), option: .network)
        default:
            loadData(with: self.paramSource?.parameters(of: self), option: .cache)
        }
    }
    
    public func loadData(with parameters: Parameters?) {
        switch self.cache {
        case .noCache:
            loadData(with: parameters, option: .network)
        default:
            loadData(with: parameters, option: .cache)
        }
    }
    
    //Mark: Privite
    
    func loadData(with parameters: Parameters?, option: LoadDataOption?) {
        
        ///ignore muti request
        if self.shouldAllowMutiRequest == false && self.isLoading == true {
            return
        }
        
        var parameters = parameters        
        parameters = fix(with: parameters)
        
        //stop if paramters didn't pass valide
        if shouldCallAPI(with: parameters) == false {
            self.status = .paramError
            failedOnCalling(response: nil, status: .paramError)
            return
        }
        
        if let reachabilityManager = NetworkReachabilityManager() {
            if reachabilityManager.isReachable == false {
                failedOnCalling(response: nil, status: .noNetwork)
                return
            }
        }
        
        let loadDataOption = option ?? .network
        switch loadDataOption {
        case .network:
            //发送请求
            loadFromNetwork(with: parameters)
        case .cache:
            //先尝试从本地读取数据
            loadFromCache(with: parameters)
        }
    }
    
    func loadFromNetwork(with parameters: Parameters?) {
        Task.request(type: self.requestType, service: self.service, methodName: self.methondName, params: parameters, success: { (response) in
            self.successOnCalling(response: response)
        }) { (response) in
            self.failedOnCalling(response: response, status: .noRequest)
        }
    }
    
    func loadFromCache(with parameters: Parameters?) {
        
        DispatchQueue.main.async {
            let cacheKey = self.cacheKey(by: parameters)
            let cacheObject = self.pinCache?.object(forKey: cacheKey)
            
            guard let result = cacheObject else {
                self.loadFromNetwork(with: parameters)
                return
            }
            
            let response = Response(data: result as? Data, requestParamters: parameters, error: nil, isCache: true)
            
            #if DEBUG
            if let resultData = result as? Data {
                let contentString = String(data: resultData, encoding: .utf8) ?? ""
                Logger.log(response: nil, responseString: contentString, requst: nil, error: nil)
            }
            #endif
            
            self.successOnCalling(response: response)
        }
        
    }
    
    func successOnCalling(response: Response) {
        
        self.isLoading = false;
        self.response = response
        
        if let content = response.content {
            self.fetchedRawData = content
        }else {
            self.fetchedRawData = response.data
        }
        
        service?.handleRequestResult(response: response)
        
        switch cache {
        case .cache:
            if response.isCache == false, let data = response.data {
                let key = cacheKey(by: response.requestParamters)
                self.pinCache?.setObject(data, forKeyedSubscript: key)
            }
        default: break
        }
        
        guard let _callback = self.callBack else {
            return
        }
        
        if let _validator = self.validator {
            if _validator.isCorrect(manager: self, ofCallback: response.content) {
                if beforePerfomSuccess(with: response) {
                    _callback.requestDidSuccess(by: self)
                }
                afterPerformSuccess(with: response)
            }else {
                failedOnCalling(response: response, status: .noContent)
            }
        }else {
            if beforePerfomSuccess(with: response) {
                _callback.requestDidSuccess(by: self)
            }
            afterPerformSuccess(with: response)
        }
    }
    
    func failedOnCalling(response: Response?, status: ManagerStatus) {
        
        self.isLoading = false
        self.response = response
        self.service?.handleRequestResult(response: response)
        self.status = status
        
        if let content = response?.content {
            self.fetchedRawData = content
        }else {
            self.fetchedRawData = response?.data
        }
        
        if beforePerformFail(with: response) {
            if let _callback = self.callBack {
                _callback.requestDidFailed(by: self)
            }
        }
        afterPerfomFail(with: response)
        
    }
    
    //Mark Intercept
    
    open func beforePerfomSuccess(with response: Response?) -> Bool {
        var result = true
        self.status = .success
        
        if let interceptor = self.interceptor {
            result = interceptor.beforeSuccess(manager: self, response: response)
        }
        return result
    }
    

    open func afterPerformSuccess(with response: Response?) {
        self.interceptor?.afterSuccess(manager: self, response: response)
    }

    open func beforePerformFail(with response: Response?) -> Bool {
        var result = true
        self.status = .success
        
        if let interceptor = self.interceptor {
            result = interceptor.beforeFailed(manager: self, response: response)
        }
        return result
    }
    

    open func afterPerfomFail(with response: Response?) -> Void {
        self.interceptor?.afterFailed(manager: self, response: response)
    }
    
    //MARK privite
    
    func shouldCallAPI(with paramters: Parameters?) -> Bool {
        if let validator = self.validator {
            return validator.isCorrect(manager: self, ofParamters: paramters)
        }else {
            return true
        }
    }
    
    func cacheKey(by parameters: Parameters?) -> String {
        
        let serverName = String(describing: type(of: self.service))
        let methodName = self.methondName
        
        guard let param = parameters else {
            return "\(serverName)-\(methodName)"
        }
        
        let parametersArray = param.reduce(Array<String>()) { (result, arg1) -> Array<String> in
            var tempResult = result
            let (key, value) = arg1
            var object: String
            if (value is String) == false {
                object = String(describing: value)
            }else {
                object = value as! String
            }
            if object.count > 0 {
                tempResult.append("\(key)=\(value)")
            }
            tempResult.sort()
            return tempResult
        }
        
        var parametersString = ""
        for item in parametersArray {
            if parametersString.count == 0 {
                parametersString.append(item)
            }else {
                parametersString.append("&\(item)")
            }
        }
        
        return "\(serverName)-\(methodName)-\(parametersString)-\(cacheRefer ?? "")"
    }
    
    
}





