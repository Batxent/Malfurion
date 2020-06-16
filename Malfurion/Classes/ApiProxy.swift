//
//  ApiProxy.swift
//  Malfurion
//
//  Created by Shaw on 2020/3/16.
//  Copyright © 2020 Dawa Inc. All rights reserved.
//

import Foundation
import Alamofire

typealias ResponseHandler = ((Response) -> Void)

struct ApiProxy {
    
    static func request(method: HTTPMethod,
                        service: Service,
                        path: String,
                        parameters: Parameters?,
                        contentType: String?,
                        success: @escaping ResponseHandler,
                        failed: @escaping ResponseHandler) -> String {
        
        let url = service.completeUrl(path: path)
        var header = service.httpHeader()
        
        print("\n==================================\n\nRequest Start: \n\n \(url)\n\n==================================")
        
        print("param: \(String(describing: parameters))")
        print("param: \(String(describing: header))")
        
        return AF.request(url, method: method,
                          parameters: parameters,
                          headers: header)
            .response { (response) in
                let _response = Response(dataResponse: response, requestParameters: parameters)
                print("\n==================================\n\nRequest End: \n\n \(url)\n\n==================================")
                debugPrint(response)
                if (response.error == nil) {
                    success(_response)
                }else {
                    failed(_response)
                }
        }.id.uuidString
        
    }
}
