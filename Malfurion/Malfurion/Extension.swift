//
//  Extension.swift
//  Malfurion
//
//  Created by Shaw on 05/07/2018.
//  Copyright © 2018 Forcewith Co., Ltd. All rights reserved.
//

import Foundation

extension String {
    
    mutating func append(request: URLRequest) -> Void {

        if let url = request.url {
             self.append(contentsOf: "\n\nHTTP URL:\n\t\(String(describing: url.absoluteString))")
        }else {
             self.append(contentsOf: "\n\nHTTP URL:\n\t\\t\t\t\t\tN/A")
        }
        
        if let headerFields = request.allHTTPHeaderFields {
            self.append(contentsOf: "\n\nHTTP Header:\n\(headerFields)")
        }else {
            self.append(contentsOf: "\n\nHTTP Header:\n\t\t\t\t\tN/A")
        }
        
        if let httpBody = request.httpBody, let dataString = String(data: httpBody, encoding: .utf8) {
            self.append(contentsOf: "\n\nHTTP Body:\n\t\(dataString)")
        }else {
            self.append(contentsOf: "\n\nHTTP Body:\n\t\t\t\t\tN/A")
        }
        
    }
    
    
}


//- (void)dew_appendURLRequest:(NSURLRequest *)request
//{
//    [self appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
//    [self appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
//    [self appendFormat:@"\n\nHTTP Body:\n\t%@", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] dew_defaultValue:@"\t\t\t\tN/A"]];
//}

