//
//  ApiTemplate.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/12.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation
import Alamofire
import PINCache

open class ApiTemplate: Api {
    
    public var status: ApiStatus = .prepare
    
    public var service: Service = DefaultService()
    
    public var path: String = ""
    
    public var method: HTTPMethod = .get
    
    public var contentType: String?
    
    public var cacheAge: TimeInterval = 0.0
    private var ignoreCache: Bool = false
    
    public var extraParam: Alamofire.Parameters?
    
    public var validator: Validator?
    
    public var delegate: ApiDelegate?
    public var parameterSource: ParameterSource?
    
    public var response: Response?
    
    public var requestIds: Array = Array<String>()
    
    lazy var pinCache: PINCache? = {
        switch self.cacheAge {
        case 0:
            return nil
        default:
            let cache = PINCache(name: String(describing: type(of: self)))
            cache.diskCache.ageLimit = cacheAge
            cache.memoryCache.ageLimit = cacheAge
            return cache
        }
    }()
    
    public init() {
        
    }
    
    deinit {
        
    }
    
    public func reforming(parameters: Parameters?) -> Parameters? {
        return parameters;
    }
    
    @discardableResult
    public func fetch() -> String? {
        return fetch(with: self.parameterSource?.parameters(self))
    }
    
    @discardableResult
    public func fetchWithoutCache() -> String? {
        self.ignoreCache = true
        return fetch()
    }
    
    @discardableResult
    public func fetch(with parameters: Parameters?) -> String? {
        
        var finalParameters = parameters
        if let extraParamFromApi = self.extraParam {
            finalParameters?.merge(extraParamFromApi, uniquingKeysWith: { return $1 })
        }
        
        if let extral = service.parameters() {
            finalParameters?.merge(extral, uniquingKeysWith: { return $1 })
        }
        
        let reformedParameters = reforming(parameters: finalParameters)
        
        if !(self.delegate?.apiShouldContinueToFetch(self, with: reformedParameters) ?? true) {
            return nil
        }
        
        if !validate(parameters: reformedParameters) {
            self.status = .parameterNonvalid
            fetchFailed(response: nil)
            return nil
        }
        
        if self.ignoreCache == false {
            // 检查缓存
            let key = cacheKey(with: reformedParameters)
            if pinCache?.containsObject(forKey: key) ?? false {
                self.status = .fetching
                if let value = pinCache?.object(forKey: key) as? Data {
                    let response = Response(data: value)
                    print("\n==================================\n\nRequest End: \n\n \(self.path)\n\n==================================")
                    debugPrint(response)
                    DispatchQueue.main.async {
                        self.fetchSuccess(response: response)
                    }
                    return nil
                }
            }
        }
        
        /// ignoreCache only works at once
        if self.ignoreCache == true {
            self.ignoreCache = false
        }
        
        if reachable() {
            self.status = .fetching
            return ApiProxy.request(method: self.method, service: self.service, path: self.path, parameters: reformedParameters, contentType: self.contentType, success: self.fetchSuccess, failed: self.fetchFailed)
        }else {
            self.status = .networkUnreachable
            return nil
        }
        
    }
    
    func fetchSuccess(response: Response) {
        self.response = response
        if self.validator?.validate(response: response) ?? true {
            self.status = .success
            self.delegate?.apiDidSuccess(self
                , with: response)
            if self.cacheAge > 0 && !response.cache {
                if let data = response.dataResponse?.data {
                    let _data = NSData(data: data)
                    self.pinCache?.setObject(_data, forKey: cacheKey(with: response.requestParameters), block: nil)
                }
            }
        }else {
            self.status = .responseNonvalid
            self.delegate?.apiDidFailed(self
                , with: response)
        }
        service.handle(response)
    }
    
    func fetchFailed(response: Response?) {
        //        self.status = .timeout
        self.delegate?.apiDidFailed(self, with: response)
        service.handle(response)
    }
    
    /// 验证请求参数是否正确
    /// - Parameter parameters: 请求参数
    func validate(parameters: Parameters?) -> Bool {
        guard let parameters = parameters else { return true }
        if let validator = self.validator {
            return validator.validate(parameters: parameters)
        }else {
            return true
        }
    }
    
    func reachable() -> Bool {
        return NetworkReachabilityManager.default?.isReachable ?? false
    }
    
}
