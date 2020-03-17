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
    
    public var cacheAge: TimeInterval = 0.0
    
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
    public func fetch(with parameters: Parameters?) -> String? {
        let reformedParameters = reforming(parameters: parameters)
        
        if !(self.delegate?.apiShouldContinueToFetch(self, with: parameters) ?? true) {
            return nil
        }
        
        if !validate(parameters: reformedParameters) {
            self.status = .parameterNonvalid
            fetchFailed(response: nil)
            return nil
        }
        
        // 检查缓存
        let key = cacheKey(with: parameters)
        if pinCache?.containsObject(forKey: key) ?? false {
            self.status = .fetching
            pinCache?.object(forKey: key, block: { (cache, key, value) in
                let response = Response(data: value as? Data)
                self.fetchSuccess(response: response)
            })
            return nil
        }else {
            if reachable() {
                self.status = .fetching
                return ApiProxy.request(method: self.method, service: self.service, path: self.path, parameters: parameters, success: self.fetchSuccess, failed: self.fetchFailed)
            }else {
                self.status = .networkUnreachable
                return nil
            }
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
        self.status = .timeout
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
