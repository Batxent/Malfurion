//
//  Task.swift
//  Malfurion
//
//  Created by Shaw on 04/07/2018.
//  Copyright © 2018 Forcewith Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire

public typealias HTTPHeaders = [String: String]
typealias ResponseCallBack = ((Response) -> Void)

struct Task {

    static func request(type: HTTPMethod, service: Service?, methodName: String?, params: Parameters?, success: @escaping ResponseCallBack, failed: @escaping ResponseCallBack) -> Void {
        
        //若service 或者methodName 或者requestURL 不存在，则不发请求
        guard let aService = service, let aMethodName = methodName, let requestURL = URL(string: aService.url(methodName: aMethodName))else {
            return
        }
        
        var totalParams = params
        if let extralParams = aService.extraParmas() {
            totalParams?.merge(extralParams, uniquingKeysWith: { return $1 })
        }
        
        print("\n==================================\n\nRequest Start: \n\n \(requestURL)\n\n==================================")

//        var requestHeader: HTTPHeaders = ["":""]
//        if let header = aService.httpHeader() {
//            requestHeader = header
//        }
//        requestHeader["Content-Type"] = "application/json"
        
        
        Alamofire.request(requestURL, method: type, parameters: totalParams, encoding: JSONEncoding(), headers: aService.httpHeader()).response { (response) in
            let customResponse = Response(data: response.data, requestParamters: totalParams, error: response.error, isCache: false)
            
            if response.error != nil {
                failed(customResponse)
            }else {
                success(customResponse)
            }
            Logger.log(response: response.response, responseString: customResponse.contentString, requst: response.request, error: response.error)
        }
        
        
//        Alamofire.request(requestURL, method: type, parameters: totalParams, encoding: .URLEncodedInURL, headers: requestHeader)
        
        
//        Alamofire.request(requestURL, method: type, parameters: totalParams, headers: requestHeader).response { (response) in
//
//        }
        
    }
    
}
