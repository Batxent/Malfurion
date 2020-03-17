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
                        success: @escaping ResponseHandler,
                        failed: @escaping ResponseHandler) -> String {
        
        let url = service.completeUrl(path: path)
        
        var finalParameters = parameters
        if let extral = service.parameters() {
            finalParameters?.merge(extral, uniquingKeysWith: { return $1 })
        }
        
        print("\n==================================\n\nRequest Start: \n\n \(url)\n\n==================================")
        
        return AF.request(url, method: method,
                          parameters: finalParameters,
                          headers: service.httpHeader())
            .response { (response) in
                let _response = Response(dataResponse: response, requestParameters: finalParameters)
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
