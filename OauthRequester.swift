//
//  OauthRequester.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Foundation

class OAuthRequester: NSObject { //, OAuthRequest {
    
    private var url : URL? = nil
    private var deviceToken : String? = nil
    private var clientToken : String? = nil
    private var accessToken : String? = nil
    private var clientId    : String? = nil
    
    private var clientData : TokenModel!
    private var accessData : TokenModel!
    
    private var retryRequest : Bool! = false
    private var invalidDevice : Bool! = false
    
    override init() {
        
    }
    
    init(withUrl url: URL) {
        self.url = url
        
    }
    
    init(withStringUrl url: String) {
        self.url = URL(string: url)
        
    }
    
    //TODO: getter token
    
    private func retry() -> Bool {
        return retryRequest
    }
    
    private func invalid() -> Bool {
        return invalidDevice
    }
    
    //setter DataStore
    //func setDataStore(SharedDataStore :)
    
    func fetch(url : URL, requestData : RequestData){ //( requestData : RequestData, withToken token: Token) {
        let request = URLRequest(url: url)
        self.executeHttpRequest(request: request, requestData: requestData)
    }
    
    func executeHttpRequest(request : URLRequest, requestData : RequestData){
        
        let session = URLSession(configuration: .default, delegate: requestData , delegateQueue: nil)
        let dataTask = session.dataTask(with: request.url!)
        dataTask.resume()
    }
    
}

