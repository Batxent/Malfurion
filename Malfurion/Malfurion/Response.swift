//
//  Response.swift
//  Medico
//
//  Created by Shaw on 2018/5/24.
//  Copyright © 2018 Forcewith Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire

enum ResponseStatus {
    case success
    case timeOut
    case noNetwork
    case noData
}

public struct Response {

    /// 用于输出显示
    public let contentString: String
    public let content: Any?
   
    public let data: Data?

    let status: ResponseStatus
    let requestParamters: Alamofire.Parameters?
    var isCache: Bool
    let error: Error?
    
    init(data: Data?, requestParamters: Alamofire.Parameters?, error: Error?, isCache: Bool) {
        
        self.data = data
        self.requestParamters = requestParamters
        self.isCache = isCache
        self.error = error
        
        guard let result = data else {
            contentString = ""
            content = nil
            status = .noData
            return
        }

        do {
            content = try JSONSerialization.jsonObject(with: result, options: .mutableContainers)
        }catch {
            content = nil
            print(error.localizedDescription)
        }

        contentString = String(data: result, encoding: .utf8) ?? ""
        
        if let aError = error {
            if aError._code == URLError.timedOut.rawValue {
                self.status = .timeOut
            }else {
                self.status = .noNetwork
            }
        }else {
            self.status = .success
        }
        
    }
}

extension Response {

    public var contentDictionary: Dictionary<String, Any>? {

        if let content = self.content, content is Dictionary<String, Any> {
            let resultDictionary = content as! Dictionary<String, Any>
            return resultDictionary
        }
        
        return nil
    }
}



