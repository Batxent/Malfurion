//
//  Service.swift
//  Malfurion
//
//  Created by Shaw on 03/07/2018.
//  Copyright © 2018 Forcewith Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire

public protocol ServiceProtocol {
    var baseUrl: String { get }
    var version: String { get }
    
    //optional
    //添加额外参数
    func extraParmas() -> Parameters?
    
    //extal headers
    func httpHeader() -> HTTPHeaders?
    
    //统一处理请求结果
    func handleRequestResult(response: Response?) -> Void
    
    //url generate
    
    /// 根据API拼接最后的Url
    /// - Parameter methodName: eg. user/login
    func url(methodName: String) -> String
    
}

extension ServiceProtocol {

    public func url(methodName: String) -> String {
        var urlString = baseUrl
        
        if version.count != 0 {
            urlString.append("/\(version)")
        }
        
        if methodName.count != 0 {
            urlString.append("/\(methodName)")
        }
        return urlString;
    }
    
}

struct ServiceItem: ServiceProtocol {
    var baseUrl: String
    var version: String
    
    func extraParmas() -> Parameters? {
        return nil
    }
    
    func httpHeader() -> HTTPHeaders? {
        return nil
    }
    
    func handleRequestResult(response: Response?) -> Void {
        return
    }
}

extension ServiceItem: ExpressibleByStringLiteral {

    typealias StringLiteralType = String

    public init(stringLiteral value: ServiceItem.StringLiteralType) {
        let items = value.components(separatedBy: ",")
        self.init(baseUrl: items.first!, version: items.last!)
    }

    public init(extendedGraphemeClusterLiteral value: ServiceItem.StringLiteralType) {
        let items = value.components(separatedBy: ",")
        self.init(baseUrl: items.first!, version: items.last!)
    }

    public init(unicodeScalarLiteral value: String) {
        let items = value.components(separatedBy: ",")
        self.init(baseUrl: items.first!, version: items.last!)
    }
}

open class Service: ServiceProtocol {
    
    var serviceItem : ServiceItem

    public var version: String {
        return self.serviceItem.version
    }
    
    public var baseUrl: String {
        return self.serviceItem.baseUrl
    }
    
    ///environment : "\(baseUrl),\(version)"
    public init(environment: String) {
        self.serviceItem = ServiceItem(stringLiteral: environment)
    }
    
    open func extraParmas() -> Parameters? {
        return nil
    }
    
    open func httpHeader() -> HTTPHeaders? {
        return nil
    }
    
    open func handleRequestResult(response: Response?) -> Void {
        return
    }
    
}

/* 子类Service 例子：
class TestService: Service {
    enum Environment: String {
        case development = "google.com,v1"
        case distribution = "baidu.com,v1"
    }
    
    let environment: Environment
    init(enviomentEnum: Environment) {
        self.environment = enviomentEnum
        super.init(environment: self.environment.rawValue)
    }
}
*/


