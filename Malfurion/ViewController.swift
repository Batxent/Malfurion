//        let request = self.sessionManager.request(URL(string: ""), method:, parameters: totalParams, headers: aService.httpHeader())//
//  ViewController.swift
//  Malfurion
//
//  Created by Shaw on 29/06/2018.
//  Copyright © 2018 Forcewith Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire

class TestService: Service {
    enum Environment: String {
        case development = "http://qihuan.imgets.com:7778,v1"
        case distribution = "http://yzh.richindoc.com,v1"
    }
    
    let environment: Environment
    init() {
        self.environment = .development
        super.init(environment: self.environment.rawValue)
    }

    override func httpHeader() -> HTTPHeaders? {
        return ["U-Token":"nonnnnnn"]
    }
    
    override func extraParmas() -> Parameters? {
        return nil
    }
    
    override func handleRequestResult(response: Response?) {
    
    }
}

class TestManager: Manager, Validator {
   
    override init() {
        super.init()
        
        self.service = TestService()
        self.methondName = "account/auth"
        self.cache = .noCache
        
        self.validator = self
    }
    
    func isCorrect(manager: ManagerProtocol, ofCallback data: Any?) -> Bool {
        guard let result = data, result is Dictionary<String, Any> else { return false }
        
        let resultDictionary = result as! Dictionary<String, Any>
        if let status = resultDictionary["status"] {
            if status is String {
                 return status as! String == "success"
            }
        }
         return false
    }
    
    func isCorrect(manager: ManagerProtocol, ofParamters data: Parameters?) -> Bool {
        return true
    }
    
}

class ViewController: UIViewController, CallBack, ParameterSource {

    override func viewDidLoad() {

        let apiManage = TestManager()
        apiManage.callBack = self
        apiManage.paramSource = self
        apiManage.loadData()
    
    }
    
    func parameters(of manager: Manager) -> Parameters? {
        return ["1": "1"]
    }

    func requestDidSuccess(by manager: Manager) {

    }

    func requestDidFailed(by manager: Manager) {

    }
    
}

