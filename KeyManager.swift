//
//  KeyManager.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 04.12.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Foundation
import CoreFoundation
import Security

class KeyManager {
    
    private var resourcePath : String?
    
    init(resourcePath : String){
        self.resourcePath = resourcePath
    }
    
    
    func changeResourcePath(path : String){
        self.resourcePath = path
    }
    
    func  getPublicKey () -> SecKey? {
        
        let certData = NSData(contentsOfFile: resourcePath!)
        let cert = SecCertificateCreateWithData(nil, certData! as CFData)
        var publicKey : SecKey? = nil
        var trust : SecTrust? = nil
        var policy : SecPolicy? = nil
        if(cert != nil) {
            policy = SecPolicyCreateBasicX509()
            if policy != nil  {
                if( SecTrustCreateWithCertificates(cert!, policy, &trust) == noErr){
                    var result : SecTrustResultType = SecTrustResultType.unspecified
                    let res = SecTrustEvaluate(trust!, &result)
                    print(res)
                    //recoverableTrustFailure
                    if(result == SecTrustResultType.proceed || result == SecTrustResultType.recoverableTrustFailure){
                        publicKey = SecTrustCopyPublicKey(trust!)
                    }
                }
            }
        }
        return publicKey
    }
    
    func getCertificate() -> SecCertificate? {
        
        if let data = NSData(contentsOfFile: resourcePath!) {
            
            //let cfData = CFDataCreate(kCFAllocatorDefault, UnsafePointer<UInt8>(data.bytes), data.length)
            let cert = SecCertificateCreateWithData(kCFAllocatorDefault, data as NSData)
            return cert
        }
        return nil
    }
    
    func getPrivateKey() -> SecKey? {
        
        let data = NSData(contentsOfFile: resourcePath!)
        
        let options = NSMutableDictionary()
        var privateKey : SecKey? = nil
        options.setObject("password", forKey: kSecImportExportPassphrase as! NSCopying)
        var items = CFArrayCreate(nil, nil, 0, nil)
        var securityError = SecPKCS12Import(data!, options as CFDictionary, &items)
        if ( securityError == noErr && CFArrayGetCount(items) > 0 ) {
            let identityDict : CFDictionary = CFArrayGetValueAtIndex(items, 0) as! CFDictionary
            var keyIdentity = kSecImportItemIdentity
            let identityApp : SecIdentity = CFDictionaryGetValue(identityDict, &keyIdentity) as! SecIdentity
            
            securityError = SecIdentityCopyPrivateKey(identityApp, &privateKey)
            if(securityError != noErr){
                privateKey = nil
            }
        }
        return privateKey
    }
    
    func cutHeaderFooterPem (certString : inout String) {
        //CUT HEADER AND TAIL FROM PEM KEY
        let offset = ("-----BEGIN RSA PRIVATE KEY-----").count
        let index = certString.index(certString.startIndex, offsetBy: offset+1)
        
        let tail = "-----END RSA PRIVATE KEY-----"
        if let lowerBound = certString.range(of: tail)?.lowerBound {
            certString = String(certString[index ..< lowerBound])
            print(certString as Any)
        }
    }
    
    class func generateKeyPair(keyTag : String , keyType : String) -> [String : SecKey]? {
        let tag = keyTag.data(using: .utf8)
        var keysResult : [String : SecKey] = [:]
        let attributes : [String : Any] = [ kSecAttrKeyType as String : keyType,
                                             kSecAttrKeySizeInBits as String : 2048,
                                             kSecPrivateKeyAttrs as String : [kSecAttrIsPermanent as String : true,
                                                                              kSecAttrApplicationTag as String : keyTag ]
                                            ]
        //kSecattrIsPermanent == true -> store the keychain in the default keychain while creating it, use the application tag to retrieve it from keychain later
        var error : Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print(error.debugDescription)
            return nil
        }
        keysResult["private"] = privateKey
        keysResult["public"] = SecKeyCopyPublicKey(privateKey)
        
        return keysResult
    }
    
    func getKeyFromPEM() -> SecKey? {
        var keyInString : String?
        do{
            keyInString = try String(contentsOfFile: resourcePath!)
        } catch { print(error)}
        
        print("PEM BEFORE  : " , keyInString!)
        //Extracting the Header and Footer from the PEM data to get the RSA key
        cutHeaderFooterPem(certString: &keyInString!)
        
        
        let data = NSData(base64Encoded: keyInString!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        print("BEFORE CUT : " , data!)
        //        let range = NSRange.init(location: 26, length: (data?.length)! - 26)
        //        let subdata = data?.subdata(with: range)
        
        print("DATA :" , data?.length as Any)
        var attributes : [String : String]  = [:]
        attributes[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA as String
        attributes[kSecAttrKeyClass as String] = kSecAttrKeyClassPrivate as String
        attributes[kSecAttrKeySizeInBits as String] = String(2048) //String((data?.length)!) * 8)
        var error : Unmanaged<CFError>?
        
        let privateKey = SecKeyCreateWithData(data! as CFData, attributes as CFDictionary, &error)
        print(error.debugDescription)
        return privateKey
    }
    
    func jwksToPem() -> String? {
        var dataFromPath = NSData(contentsOfFile: self.resourcePath!)
        var jsonData : [String : Any]?
        var pemResult : String?
        do{
            jsonData = try JSONSerialization.jsonObject(with: dataFromPath as Data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any]
        }catch{
            print(error)
            return nil
        }
        
        let keys = jsonData!["keys"] as! [[String: String]]
        
        if keys.count == 1 {
            let key = keys.first
            print("KEY  = \(key!)")
            pemResult = jwkToPem(key: key!)
        }
        return pemResult
    }
    
    func jwkToPem(key : [String : String]) -> String? {
        
        var exponentStr = base64UrlToBase64(base64url: key["e"]!)
        while exponentStr.count % 4 != 0{
            exponentStr += "="
        }
        let exponentData = Data(base64Encoded: exponentStr)

        var modulusStr = base64UrlToBase64(base64url: key["n"]!)
        while modulusStr.count % 4 != 0{
            modulusStr += "="
        }
        let modulusData = Data(base64Encoded: modulusStr)
        print("exponent : \(exponentStr)")
        print("modulus : \(modulusStr)")
        let pemGen = PemGenerator(modulusHex: (modulusData?.hexDescription)!, exponentHex: (exponentData?.hexDescription)!, lengthModulus: (modulusData?.count)!, lengthExponent: (exponentData?.count)!)
        let pemString = pemGen.generatePublicPem()
        
        return pemString
    }

    private func  bytesCount (base64str : String) -> Int{
        
        var bitsCount = base64str.count * 6
        if bitsCount % 8 == 0 {
            return bitsCount / 8
        }
        else {
            return (bitsCount / 8) + 1
        }
    }
    
    private func base64UrlToBase64(base64url : String) -> String {
        let base64 = base64url.replacingOccurrences(of: "-", with: "+")
                             .replacingOccurrences(of: "_", with: "/")
        /* NO PADDING
        while(base64.count % 4 != 0){
            base64.append("=")
        }*/
        return base64
    }
    
    private func base64ToBase64Url(base64: String) -> String {
        let base64url = base64.replacingOccurrences(of: "+", with: "-")
                            .replacingOccurrences(of: "/", with: "_")
        return base64url
    }
    
    func pemToJWK(pemData : Data) -> [String: String]{
        var jwk : [String : String] = [:]
        print("LAST INDEX : \(pemData.endIndex.hashValue)")
        let rangeModulus : Range<Int> = 9..<265
        let rangeExponent : Range<Int> = Int(267)..<pemData.endIndex.hashValue
        //rangeExponent
        print("DATA SIZE :  \(pemData.count),",pemData.base64EncodedString())
        let subdataMod = pemData.subdata(in: rangeModulus)
        let subdataEx = pemData.subdata(in: rangeExponent)
        print("MOD HEX : \(subdataMod.hexDescription)")
        print("EX HEX : \(subdataEx.hexDescription)")
        jwk["n"] = base64ToBase64Url(base64: subdataMod.base64EncodedString().clearPaddding() )
        jwk["e"] = base64ToBase64Url(base64: subdataEx.base64EncodedString().clearPaddding() )
        
        return jwk
    }
    
    
    
}

extension String{
    
    public func hexToBase64() -> Data {
        var hex = self
        var data = Data()
        while hex.count > 0 {
            
            let indexHex = hex.index(hex.startIndex, offsetBy: 2)
            let c : String = String(hex[..<indexHex])
            hex = String(hex[indexHex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8 (ch)
            data.append(&char, count: 1)
        }
//        let base64Str = data.base64EncodedString()
        
        return data // base64Str.clearPaddding()
    }
    
    public func clearPaddding() -> String {
        var tmp = self
        while(tmp.last == "="){
            tmp.removeLast()
        }
        return tmp
    }
    
}

extension Data {
    var hexDescription : String {
        return reduce(""){$0 + String(format: "%02x", $1)}
    }
}
