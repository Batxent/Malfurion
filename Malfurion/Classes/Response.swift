//
//  Response.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/9.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation
import Alamofire

public struct Response {
    
    // dictionary<String, Any?> as usual
    let content: Any?
    
    let dataResponse: AFDataResponse<Data?>?
    
    let requestParameters: Parameters?
    
    let httpSuccess: Bool
    
    let cache: Bool
    
    init(data: Data?) {
        self.dataResponse = nil
        self.requestParameters = nil
        self.httpSuccess = false
        self.cache = true
        guard let data = data else {
            self.content = nil
            return
        }
        do {
            self.content = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            self.content = nil
            print(error.localizedDescription)
        }
    }
    
    init(dataResponse: AFDataResponse<Data?>, requestParameters: Parameters? = nil) {
        self.dataResponse = dataResponse
        self.requestParameters = requestParameters
        self.httpSuccess = dataResponse.error == nil
        self.cache = false
        
        guard let data = dataResponse.data else {
            self.content = nil
            return
        }
        
        do {
            self.content = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            self.content = nil
            print(error.localizedDescription)
        }
    }
}

