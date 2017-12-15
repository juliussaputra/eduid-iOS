//
//  AppDelegate.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import UIKit
import CoreData
import Security
import CoreFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //jwk to pem PKCS#1
        let pubPath = Bundle.main.url(forResource: "eduid_pub", withExtension: "jwks")
        print("Public key Path : \(pubPath?.path ?? " ")")
        let keyman = KeyManager(resourcePath: (pubPath?.relativePath)!)
        let keyStr = keyman.jwksToPem()
        let keyData = Data(base64Encoded: keyStr!)
        let options : [String : Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA as String,
                                        kSecAttrKeyClass as String: kSecAttrKeyClassPublic as String,
                                        kSecAttrKeySizeInBits as String : 2048,
                                        ]
        var error : Unmanaged<CFError>?
        let publickey = SecKeyCreateWithData(keyData! as CFData, options as CFDictionary, &error)
        if(error != nil) {
            print(error.debugDescription)
            return true
        }
        let attributes = SecKeyCopyAttributes(publickey!) as! NSDictionary
        let size = SecKeyGetBlockSize(publickey!)
        print("SIZE : " , size)
        print("ATTRIBUTES : " , attributes["type"] , kSecAttrKeyTypeRSA as String)
        
        let supported = SecKeyIsAlgorithmSupported(publickey!, SecKeyOperationType.encrypt, SecKeyAlgorithm.rsaEncryptionPKCS1)
        print("KEYSTR : \(keyStr!)")
        guard let keyFromChain = SecKeyCopyExternalRepresentation(publickey!, &error)! as? Data else {
            print(error.debugDescription)
            return true
        }
        print("key : \(keyFromChain.base64EncodedString() )")
        print("Key hex : \(keyFromChain.hexDescription) ")
        
        let jwkDict  = keyman.pemToJWK(pemData: keyFromChain)
        print(jwkDict)
        
        /*
         //get public key
         let urlPath = Bundle.main.url(forResource: "rsaCert", withExtension: ".der")
         print("url path : " , urlPath?.absoluteString as Any)
         
         var keyMan = KeyManager.init(resourcePath: (urlPath?.relativePath)!)
         let publickey = keyMan.getPublicKey()
         print(publickey.debugDescription)
         
         //encrypt data with public key
         let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA512
         print("SECkeyBlockSize : " , SecKeyGetBlockSize(publickey!))
         let plainText = "I AM LOCKED, PLEASE UNLOCK ME"
         let cipherText = CryptoManager.encryptData(key: publickey!, algorithm: algorithm, plainData: plainText.data(using: String.Encoding.utf8)! as NSData)
         print("CIPHER TEXT : " , cipherText?.base64EncodedString() ?? "error by encryption")
         
         
         //get private key from pem
         keyMan = KeyManager(resourcePath: (Bundle.main.url(forResource: "ios_priv", withExtension: ".pem")?.relativePath)!)
         let privateKey = keyMan.getKeyFromPEM()
         
         print(privateKey.debugDescription)
         
         //Decrypt with private key
         guard SecKeyIsAlgorithmSupported(privateKey!, .decrypt, algorithm) else {
         print("NOT SUPPORTED")
         return false
         }
         if cipherText?.count == SecKeyGetBlockSize(privateKey!){
         print("SAME LENGTH")
         }
         var error: Unmanaged<CFError>?
         guard let cleartext = SecKeyCreateDecryptedData(privateKey!, algorithm, cipherText! as CFData, &error) as Data?  else {
         print("ERROR DECRYPTING : " , error?.takeRetainedValue().localizedDescription ?? "error")
         return false
         }
         
         
         print("DECRYPTED : " , String.init(data: cleartext, encoding: .utf8) )
         
         
         let status = KeyChain.saveKey(tagString: "privateKey", key: privateKey!)
         print("STATUS : " , status)
         */
        //        let keyExtra = KeyChain.loadKey(tagString: "privateKey")
        //        print("SVED : " ,keyExtra.debugDescription)
        
        keygeneratortest()
        
        return true
    }
    
    func keygeneratortest() {
        let keydict = KeyManager.generateKeyPair(keyTag: "htwchur.keys", keyType: kSecAttrKeyTypeRSA as String)
        if(keydict == nil){
            print("NILLLL")
        }
        
        let keyFromKeychain = KeyChain.loadKey(tagString: "htwchur.keys")
        print(keydict!["private"])
        print(keydict!["public"])
        print(keyFromKeychain!)
        print(KeyChain.deleteKey(tagString: "htwchur.keys"))
        
    }
    
    func work( p: UnsafeMutablePointer<Float>?){
        if p != nil {
            p?.pointee = 10
        }
        print("POINTER : ",p!)
        print(p?.pointee as Any)
    }
    
    func printPaths(paths : [URL]){
        for path in paths{
            print("path : " , path.absoluteString)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "eduid_iOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

