//
//  Service.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/9.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation
import Alamofire

public protocol Service {
    
    /// eg. https://xx.google.com
    var basePath: String { get }
    
    /// the web api version, eg. v2.0
    var version: String? { get }
        
    var contentType: String? { get }
    
    /// common parameters
    func parameters() -> Alamofire.Parameters?
    
    /// common header
    func httpHeader() -> Alamofire.HTTPHeaders?
    
    //统一处理请求结果
    func handle(_ response: Response?)
    
    /// 根据API拼接最后的Url
    /// - Parameter path: eg. /user/login
    func completeUrl(path: String) -> String
    
}

public extension Service {

    var version: String? {
        get {
            return nil;
        }
    }
    
    var contentType: String? {
        get {
            return nil
        }
    }
    
    func completeUrl(path: String) -> String {
        var urlString = basePath
        if let v = version, v.count != 0 {
            urlString.append("/\(v)")
        }
        if path.count != 0 {
            urlString.append("\(path)")
        }
        return urlString;
    }
    
    func handle(_ response: Response?) {}
    
    func httpHeader() -> Alamofire.HTTPHeaders? {
        return nil
    }
    
    func parameters() -> Alamofire.Parameters? {
        return nil
    }
    
}
