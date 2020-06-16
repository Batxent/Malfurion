//
//  Validator.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/9.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation

public protocol Validator {
    
    /// 验证请求参数
    /// - Parameter param: 请求参数
    func validate(parameters: Dictionary<String, Any>) -> Bool
    
    /// 验证返回参数
    /// - Parameter response: 返回参数
    func validate(response: Response) -> Bool
}

extension Validator {
    
    func validate(parameters: Dictionary<String, Any>) -> Bool { return true }
    func validate(response: Response) -> Bool { return false }
}
