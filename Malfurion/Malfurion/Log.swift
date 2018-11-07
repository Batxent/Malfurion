//
//  Log.swift
//  Malfurion
//
//  Created by Shaw on 05/07/2018.
//  Copyright © 2018 Forcewith Co., Ltd. All rights reserved.
//

import Foundation

struct Logger {
    
    static func log(response: HTTPURLResponse?, responseString: String, requst: URLRequest?, error: Error?) -> Void {
        
        #if DEBUG
        
        var logString = "\n\n==============================================================\n=                        API Response                        =\n==============================================================\n\n";

        guard let urlResponse = response, let urlReqeust = requst else {
            logString.append(contentsOf: "Content:\n\t\(responseString)\n\n")
            logString.append(contentsOf: "\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n")
            print(logString)
            return
        }
        
        logString.append(contentsOf: "Status:\t\(urlResponse.statusCode)\t(\(HTTPURLResponse.localizedString(forStatusCode: urlResponse.statusCode)))\n\n")
        logString.append(contentsOf: "Content:\n\t\(responseString)\n\n")
        logString.append(contentsOf: "\n---------------  Related Request Content  --------------\n")
        
        logString.append(request: urlReqeust)

        logString.append(contentsOf: "\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n")
        print(logString)
        
        #else
        
//        return ""
        
        #endif
        
    }
    
}

