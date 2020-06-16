//
//  ApiTemplate.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/9.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation
import Alamofire

public enum ApiStatus {
    
    /// 尚未发送请求
    case prepare
    
    /// 正在请求数据
    case fetching
    
    /// http请求成功，且返回状态为正确
    case success
    
    /// 取消
    case canceled
    
    /// 请求超时
    case timeout
    
    /// 参数验证失败
    case parameterNonvalid
    
    /// 返回数据验证失败
    case responseNonvalid
    
    ///无网络
    case networkUnreachable
    
}

public protocol Api {
    
    var service: Service { set get }
    
    var path: String { get set }
    
    var method: Alamofire.HTTPMethod { get set }
    
    /// 缓存时间，若为0，则无缓存;
    var cacheAge: TimeInterval { get set }
    
    var status: ApiStatus { get }
    
    var validator: Validator? { get set }
    
    /// 在发出请求之前对参数进行调整
    /// - Parameter parameters: 最终请求前的参数
    func reforming(parameters: Parameters?) -> Parameters?
    
    /// 返回request id, 若为nil,表示请求未发出，终止在参数检测等步骤
    @discardableResult
    func fetch() -> String?
    
    @discardableResult
    func fetch(with parameters: Parameters?) -> String?
    
}
