//
//  AuthorizationToken.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 26.01.18.
//  Copyright © 2018 Blended Learning Center. All rights reserved.
//

import Foundation
import CoreData
import JWTswift

class AuthorizationTokenModel : NSObject {
    
    private lazy var entities : [NSManagedObject] = []
    private lazy var persistentContainer : NSPersistentContainer? = nil
    private lazy var managedContext : NSManagedObjectContext? = nil
    
    private var jsonResponse : [String : Any]?
    
//    private let client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    private let grant_type = "urn:ietf:params:oauth:grant-type:jwt-bearer"
    var downloadSuccess : BoxBinding<Bool?> = BoxBinding(nil)
    
    override init() {
        super.init()
    }
    
    deinit {
        print("AuthorizationTokenModel is being deinitialized")
    }
    
    func createAssert(addressToSend : URL, subject : String , audience : String , keyToSign : Key) -> String {
        var payload = [String : Any]()
        payload["azp"] = addressToSend.absoluteString
        payload["iss"] = UIDevice.current.identifierForVendor?.uuidString
        payload["aud"] = audience
        payload["sub"] = ""
            
        var timestamp = Int(Date().timeIntervalSince1970)
        payload["iat"] = String(timestamp)
        payload["cnf"] = ["kid" : keyToSign.getKid()]
            
        payload["x_jwt"] = "asadasd"
        
        return ""
    }
    
    func fetch (address : URL, assertionBody : String ){
        
        let request = NSMutableURLRequest(url: address)
        request.httpMethod = "GET"
        print("FETCH : " , request.url)
        
        let body = [ "grant_type" : self.grant_type,
                     "assertion" : assertionBody
                    ]
        let bodyUrl = httpBodyBuilder(dict: body)
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let dataTask = session.dataTask(with: request as URLRequest)
        
        
        
    }
    
    
    
    private func extractJson(){
        
    }
    
    private func httpBodyBuilder(dict : [String: Any]) -> String {
        var resultArray = [String]()
        
        for (key,value) in dict {
            let keyEncoded =  key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let valueEncoded = (value as AnyObject).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let encodedEntry = keyEncoded + "=" + valueEncoded
            
            resultArray.append(encodedEntry)
        }
        print("HTTP BODY : " ,resultArray.joined(separator: "&"))
        return resultArray.joined(separator: "&")
    }
    
    
}

extension AuthorizationTokenModel : URLSessionDelegate {
    
}
