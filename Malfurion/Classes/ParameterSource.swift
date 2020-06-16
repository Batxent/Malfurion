//
//  ParameterSource.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/12.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation
import Alamofire

public protocol ParameterSource {
    
    func parameters(_ api: Api) -> Alamofire.Parameters
}

