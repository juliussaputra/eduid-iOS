//
//  ViewController.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var model = EduidConfigModel()
    private var requestData = RequestData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did load")
        /*
         var newData : [String : String] = [:]
         newData["cfg_name"] = "bully"
         newData["cfg_value"] = "fake dragon rider"
         
         //model.save(data: newData)
         //model.fetch()
         //model.delete(name: "bully")
         //model.deleteAll()
        // model.fetch()
         let allData = model.getAll()
        */
        
        
        // TEST THE URL REQUEST
        
//        let reqURL = URL(string: "https://eduid.htwchur.ch/oidc/.well-known/openid-   configuration")
        //model.deleteAll()
        //model.fetchServer(serverUrl: reqURL!)
        //model.fetchDatabase()
        
        
//        requester.fetch(url: reqURL!, requestData: self.requestData)
        var header : [String : Any] = [:]
        header["typ"] = "JWT"
        header["alg"] = "RS256"
        var payload : [String : Any] = [
            "iss" : "julius",
            "exp" : 2020,
            "link" : "http://google.ch"
            ]
        let privateKey = KeyChain.loadKey(tagString: "privateKey")
        let jws = JWS()
        let jwt = jws.sign(header: header, payload: payload, key: privateKey!)
        print("JWT : " , jwt!)
        
         /*
        let urlPath = Bundle.main.url(forResource: "rsaCert", withExtension: ".der")
        print("url path : " , urlPath?.absoluteString as Any)
        
        var keyMan = KeyManager.init(resourcePath: (urlPath?.relativePath)!)
        let publickey = keyMan.getPublicKey()
        let verified = jws.verify(header: header, payload: payload, signature: &jws.signatureStr!, key: publickey!)
        print(verified)
        */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
