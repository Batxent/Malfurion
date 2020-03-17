//
//  Delegate.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/12.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation
import Alamofire

public protocol ApiDelegate {
    
    func apiDidSuccess(_ api: ApiTemplate, with response: Response)
    func apiDidFailed(_ api: ApiTemplate, with response: Response?)
    
    func apiShouldContinueToFetch(_ api: ApiTemplate, with parameters: Parameters?) -> Bool
}

extension ApiDelegate {
    func apiShouldContinueToFetch(_ api: ApiTemplate, with parameters: Parameters?) -> Bool {
        return true
    }
}

