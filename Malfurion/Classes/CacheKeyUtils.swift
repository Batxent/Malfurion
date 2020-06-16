//
//  CacheKeyUtils.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/16.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation
import Alamofire

extension ApiTemplate {
    
    func cacheKey(with parameters: Parameters?) -> String {
        let serverName = String(describing: type(of: self.service))
        let path = self.path
        
        guard let param = parameters else {
            return "\(serverName)-\(path)"
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
        return "\(serverName)-\(path)-\(parametersString)"
    }
    
}

