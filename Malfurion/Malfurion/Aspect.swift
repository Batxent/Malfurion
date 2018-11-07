//
//  Aspect.swift
//  Malfurion
//
//  Created by Shaw on 04/07/2018.
//  Copyright © 2018 Forcewith Co., Ltd. All rights reserved.
//
//  @abstract Aspect Protocol


import Foundation
import Alamofire

public protocol ManagerProtocol {
    var methondName: String { get set }
    var service: Service? { get set }
    var requestType: HTTPMethod { get set }
    var cache: CacheDataOption { get set }
    var shouldAllowMutiRequest: Bool { get set } //是否允许同一个服务同时存在多个请求，比如登录服务，只允许一个
    var cacheRefer: String? { get }

    func cleanData()
    func loadData(with parameters: Parameters?)
}

public protocol CallBack {
    func requestDidSuccess(by manager: Manager)
    func requestDidFailed(by manager: Manager)
}

///验证器
public protocol Validator {
    ///  - callback: validate call back data
    func isCorrect(manager: ManagerProtocol,ofCallback data: Any?) -> Bool
    
    ///  - params: validate request parameters
    func isCorrect(manager: ManagerProtocol,ofParamters data: Parameters?) -> Bool
}

public protocol ParameterSource {
    func parameters(of manager: Manager) -> Parameters?
}

//拦截器
public protocol Interceptor {
    func beforeSuccess(manager: Manager, response: Response?) -> Bool
    func afterSuccess(manager: Manager, response: Response?) -> Void
    func beforeFailed(manager: Manager, response: Response?) -> Bool
    func afterFailed(manager: Manager, response: Response?) -> Void
}

public enum CacheDataOption {
    case noCache
    case cache(age: TimeInterval)
}
