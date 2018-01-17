//
//  ViewController.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import UIKit
import JWTswift

class LoginViewController: UIViewController {
    
    private var configModel = EduidConfigModel()
    //    private var requestData = RequestData()
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private let userDev = "ios dev"
    private let passDev = "EsfafWyegBorIdKonWacVobOshNig9"
    private var tokenEnd : URL?
    private var sessionKey : [String : Key]?
    private var signingKey : Key?
    var tokenModel : TokenModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did load")
        
        loginButton.backgroundColor = UIColor.black
        usernameTF.delegate = self
        passwordTF.delegate = self
        
        
        tokenEnd = configModel.getTokenEndpoint()
        print("Issuer = \(String(describing: configModel.getIssuer()))")
        print("TOKEN ENDPOINT = \(tokenEnd?.absoluteString ?? "error")" )
        let keystore = KeyStore()
        sessionKey = KeyStore.generateKeyPair(keyType: kSecAttrKeyTypeRSA as String)!
        var urlPathKey = Bundle.main.url(forResource: "ios_priv", withExtension: "jwks")
        let keyID = keystore.getPrivateKeyIDFromJWKSinBundle(resourcePath: (urlPathKey?.relativePath)!)
        urlPathKey = Bundle.main.url(forResource: "ios_priv", withExtension: "pem")
        guard let privateKeyID = keystore.getPrivateKeyFromPemInBundle(resourcePath: (urlPathKey?.relativePath)!, identifier: keyID!) else {
            print("ERROR getting private key")
            return
        }
        //key object always save the kid in base64-- but to send in jws it need base64url
        signingKey = keystore.getKey(withKid: privateKeyID.base64UrlToBase64())!
        
        
        //        print("ASSERT : " , clientAssert)
        //        configModel.fetchServer(serverUrl: reqURL!)
        
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
        //        self.testJWTswift()
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
    
    @IBAction func login(_ sender: Any) {
        
        guard let userSub : String = usernameTF.text , let pass : String  = passwordTF.text else{
            return
        }
        showLoadUI()
        tokenModel?.deleteAll()
        tokenModel = TokenModel(tokenURI: self.tokenEnd!)
        let userAssert = tokenModel?.createUserAssert(userSub: userSub , password: pass, issuer: userDev , audience: configModel.getIssuer()!, keyToSend: sessionKey!["public"]!, keyToSign: signingKey!)
        
        tokenModel?.fetchServer(username: userDev, password: passDev, assertionBody: userAssert!)
        
        var timeoutCounter : Float = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timerTmp in
            timeoutCounter += 0.5
            if self.tokenModel?.tokenDownloaded != nil {
                
                if (self.tokenModel?.tokenDownloaded)! {
                    print("GOT TOKEN")
                    timerTmp.invalidate()
                    self.loginSuccessful()
                    self.removeLoadUI()
                    
                }else {
                    print("Login Rejected")
                    timerTmp.invalidate()
                    self.loginUnsuccessful()
                    self.removeLoadUI()
                }
            }
            else if timeoutCounter == 5 {
                self.showAlertUI()
                timerTmp.invalidate()
                self.removeLoadUI()
            }
        }
        timer.fire()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier  != "toProfile" {
            return
        }
        
        guard let profileVC = segue.destination as? ProfileViewController else{
            return
        }
        profileVC.token = self.tokenModel
        profileVC.textLabel = usernameTF.text
//        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func loginSuccessful(){
//        let segue = self.performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
        self.performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    func loginUnsuccessful(){
        
        let alert = UIAlertController(title: "Login rejected", message: "Please check your login or username again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertUI(){
        
        let alert = UIAlertController(title: "Timeout: no connection to the server", message: "Please check your internet connection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close App", style: .default, handler: { (alertAction) in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }))
        alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showLoadUI(){
        let tmpFrame = self.view.window?.frame
        let view = UIView(frame: tmpFrame!)
        view.tag = 1
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.center = view.center
        indicator.startAnimating()
        view.addSubview(indicator)
        self.view.addSubview(view)
    }
    
    func removeLoadUI(){
        let view  = self.view.viewWithTag(1)
        view?.removeFromSuperview()
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.autocorrectionType = .no
        
        if textField == self.passwordTF {
            textField.isSecureTextEntry = true
            if textField.text == "Password"{
                textField.text = ""
            }
        } else {
            
            if textField.text == "Username" {
                textField.text = ""
            }
            
        }
    }
    
}
