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
    
    func  getPublicKey () -> SecKey? {
        
        let certData = NSData(contentsOfFile: resourcePath!)
        let cert = SecCertificateCreateWithData(nil, certData as! CFData)
        var publicKey : SecKey? = nil
        var trust : SecTrust? = nil
        var policy : SecPolicy? = nil
        if(cert != nil) {
            policy = SecPolicyCreateBasicX509()
            if policy != nil  {
                if( SecTrustCreateWithCertificates(cert!, policy, &trust) == noErr){
                    var result : SecTrustResultType = SecTrustResultType.unspecified
                    let res = SecTrustEvaluate(trust!, &result)
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
        
        var options = NSMutableDictionary()
        var privateKey : SecKey? = nil
        options.setObject("password_for_the_key", forKey: kSecImportExportPassphrase as! NSCopying)
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
        let offset = ("-----BEGIN RSA PRIVATE KEY-----").count
        let index = certString.index(certString.startIndex, offsetBy: offset+1)
        
        let tail = "-----END RSA PRIVATE KEY-----"
        if let lowerBound = certString.range(of: tail)?.lowerBound {
            certString = String(certString[index ..< lowerBound])
            print(certString)
        }
    }
    
    func getPrivateKeyPEM() -> SecKey? {
        var keyInString : String?
        do{
            keyInString = try String(contentsOfFile: resourcePath!)
        } catch { print(error)}
        
        print("BEFORE : " , keyInString!)
        cutHeaderFooterPem(certString: &keyInString!)
        let data = NSData(base64Encoded: keyInString!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        print("DATA :" , data)
        let attributes = NSMutableDictionary()
        attributes.setValue(kSecAttrKeyTypeRSA, forKey: "kSecAttrKeyType")
        attributes.setValue(kSecAttrKeyClassPrivate, forKey: "kSecAttrKeyClass")
        attributes.setValue(kSecAttrKeySizeInBits, forKey: "2048")
        let privateKey = SecKeyCreateWithData(data!, attributes, nil)
        
        return privateKey
    }
    
    
}
