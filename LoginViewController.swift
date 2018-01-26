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
    
    private var userDev: String?
    private var passDev: String?
    private var tokenEnd : URL?
    private var sessionKey : [String : Key]?
    private var signingKey : Key?
    var tokenModel : TokenModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did load")
        
        usernameTF.delegate = self
        passwordTF.delegate = self
        
        loadPlist()
        tokenEnd = configModel.getTokenEndpoint()
        print("Issuer = \(String(describing: configModel.getIssuer()))")
        print("TOKEN ENDPOINT = \(tokenEnd?.absoluteString ?? "error")" )
        
        let keystore = KeyStore()
        if !self.loadKey() {
            sessionKey = KeyStore.generateKeyPair(keyType: kSecAttrKeyTypeRSA as String)!
            self.saveKey()
        }
        var urlPathKey = Bundle.main.url(forResource: "ios_priv", withExtension: "jwks")
        let keyID = keystore.getPrivateKeyIDFromJWKSinBundle(resourcePath: (urlPathKey?.relativePath)!)
        urlPathKey = Bundle.main.url(forResource: "ios_priv", withExtension: "pem")
        
        guard let privateKeyID = keystore.getPrivateKeyFromPemInBundle(resourcePath: (urlPathKey?.relativePath)!, identifier: keyID!) else {
            print("ERROR getting private key")
            return
        }
        //key object always save the kid in base64-- but to send in jws it need base64url
        signingKey = keystore.getKey(withKid: privateKeyID.base64UrlToBase64())!
        
        tokenModel = TokenModel(tokenURI: self.tokenEnd!)
        if (tokenModel?.fetchDatabase())! {
            self.loginSuccessful()
            return
        }
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDownload(downloaded : Bool?) {
        print("checkDownload LoginVC : \(String(describing: downloaded))")
        
        self.removeLoadUI()
        
        if downloaded == nil {
            showAlertUI()
        }else if !downloaded! {
            loginUnsuccessful()
        }else {
            loginSuccessful()
        }
        
    }
    
    
    func loadPlist(){
        if let path = Bundle.main.path(forResource: "Setting", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String : Any] {
                self.userDev = dic["ClientID"] as? String
                self.passDev = dic["ClientPass"] as? String
            }
        }
    }
    
    func loadKey() -> Bool {
        sessionKey = [String : Key]()
        sessionKey!["public"] = KeyChain.loadKey(tagString: "sessionPublic")
        sessionKey!["private"] = KeyChain.loadKey(tagString: "sessionPrivate")
        if  sessionKey!["public"] != nil && sessionKey!["private"] != nil {
            
            print("Keys already existed")
            return true
            
        } else {
            return false
        }
    }
    
    func saveKey() {
        let _ = KeyChain.saveKey(tagString: "sessionPublic", keyToSave: sessionKey!["public"]!)
        sessionKey!["private"] = KeyStore.createKIDfromKey(key: sessionKey!["private"]!)
        let _ = KeyChain.saveKey(tagString: "sessionPrivate", keyToSave: sessionKey!["private"]!)
    }
    
    @IBAction func login(_ sender: Any) {
        
        guard let userSub : String = usernameTF.text , let pass : String  = passwordTF.text else{
            return
        }
        showLoadUI()
        
        tokenModel?.downloadSuccess.bind (listener: { (dlBool) in
            DispatchQueue.main.async {
                self.checkDownload(downloaded: dlBool)
            }
        })
//        tokenModel = TokenModel(tokenURI: self.tokenEnd!)
        
        let userAssert = tokenModel?.createUserAssert(userSub: userSub , password: pass, issuer: userDev! , audience: configModel.getIssuer()!, keyToSend: sessionKey!["public"]!, keyToSign: signingKey!)
        do{
            try tokenModel?.fetchServer(username: userDev!, password: passDev!, assertionBody: userAssert!)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        /*
        var timeoutCounter : Double = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timerTmp in
            timeoutCounter += timerTmp.timeInterval
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
         */
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier  != "toProfile" {
            return
        }
        
        guard let profileVC = segue.destination as? ProfileViewController else{
            return
        }
        profileVC.token = self.tokenModel
//        profileVC.textLabel = usernameTF.text
//        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func loginSuccessful(){
//        let segue = self.performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
        self.tokenModel?.downloadSuccess.listener = nil
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
