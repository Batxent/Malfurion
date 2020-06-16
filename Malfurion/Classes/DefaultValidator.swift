//
//  DefaultValidator.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/12.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation

struct DefaultValidator: Validator {
    
    func validate(response: Response) -> Bool {
        guard response.httpSuccess else {
            return false
        }
        
        if let content = response.content, content is Dictionary<String, Any> {
            let resultDictionary = content as! Dictionary<String, Any>
            return resultDictionary["code"] as? String == "0"
        }else {
            return true
        }
    }
}
