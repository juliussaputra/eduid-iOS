//
//  RequestData.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Foundation

class RequestData : NSObject {
    
    var type : String?
    var url : URL?
    
    var status : Int?
    var result  : String?
    
    var data : Any?
    var input : Any?
    
    var cbHandle : Any?
    var cbFunction : Selector?
    var parent : RequestData?
    
    var retryProp : Bool?
    var invalidDevice : Bool?
    var dataStore : SharedDataStore?
    
    override init() {
        
        self.url = nil
        self.type = nil
        self.status = nil
        self.result = nil
        
        super.init()
    }
    
    func getType () -> String {
        return self.type!
    }
    
    func setType(type : String){
        self.type = type
    }
    
    func getUrl() -> URL {
        return self.url!
    }
    
    func setUrl( url : URL) {
        self.url = url
    }
    
}


extension RequestData : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("DID RECEIVE Response")
        let httpResponse = dataTask.response as! HTTPURLResponse
        print("STATUS : " , httpResponse.statusCode)
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive reqdata: Data) {
        print("DID RECEIVE DATA")
        let httpResponse = dataTask.response as! HTTPURLResponse
        self.status = httpResponse.statusCode
        
        if(reqdata.count > 0 ){
            self.result = String(bytes: reqdata, encoding: String.Encoding.utf8)!
            print("result data : " , self.result!)
        }
    }
}

