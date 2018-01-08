//
//  ViewController.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import UIKit
import JWTswift

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
        /*
        var header : [String : Any] = [:]
        header["typ"] = "JWT"
        header["alg"] = "RS256"
        let payload : [String : Any] = [
            "iss" : "julius",
            "exp" : 2020,
            "link" : "http://google.ch"
            ]
        let privateKey = KeyChain.loadKey(tagString: "privateKey")
        let jws = JWS()
        let jwt = jws.sign(header: header, payload: payload, key: privateKey!)
        print("JWT : " , jwt!)
        */
         /*
        let urlPath = Bundle.main.url(forResource: "rsaCert", withExtension: ".der")
        print("url path : " , urlPath?.absoluteString as Any)
        
        var keyMan = KeyManager.init(resourcePath: (urlPath?.relativePath)!)
        let publickey = keyMan.getPublicKey()
        let verified = jws.verify(header: header, payload: payload, signature: &jws.signatureStr!, key: publickey!)
        print(verified)
        */
        self.testJWTswift()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func testJWTswift() {
        var dict = [
            "e"  : "AQAB",
            "kty" : "RSA",
            "n" : "0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw"]
        let kid = KeyStore.createKIDfromJWK(jwkDict: dict) as String!
        print("KID : \(String(describing: kid!))")
        dict["kid"] = kid!
        let keyStore = KeyStore.init()
        let key = keyStore.jwkToKey(jwkDict: dict)
        _ = KeyChain.deleteKey(tagString: "testKey", keyToDelete: key!)
        let saved  = KeyChain.saveKey(tagString: "testKey", keyToSave: key!)
        print("SAVED : \(saved)")
        //load the kid from keychain
        let loadKey = KeyChain.loadKey(tagString: "testKey")
        print("load key : \(loadKey!.getKeyObject())")
        print("kid and loadKid same : \(kid! == loadKey?.getKid()!)")
        
    }
}
