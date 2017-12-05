//
//  KeyChain.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 05.12.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Foundation

class KeyChain {
    
    class func saveKey(tagString: String, key: SecKey) -> OSStatus{
        let tag = tagString.data(using: .utf8)
        let saveQuery = [
            kSecClass as String : kSecClassKey as String,
            kSecAttrApplicationTag as String : tag!,
            kSecValueRef as String : key
        ] as [String : Any]
        // delete the old key if it does exist
        SecItemDelete(saveQuery as CFDictionary)
        
        return SecItemAdd(saveQuery as CFDictionary, nil)
    }
    
    class func loadKey(tagString : String) -> SecKey? {
        let tag = tagString.data(using: .utf8)
        let getQuery = [
            kSecClass as String : kSecClassKey,
            kSecAttrApplicationTag as String : tag!,
            kSecReturnRef as String : true,
            kSecAttrKeyType as String : kSecAttrKeyTypeRSA
        ] as [String : Any]
        
        var loadedKey : CFTypeRef?
        let status : OSStatus = SecItemCopyMatching(getQuery as CFDictionary, &loadedKey)
        
        if status == noErr {
            return (loadedKey as! SecKey)
        } else {
            return nil
        }
    }
    
    class func createUniqueID() -> String {
        let uuid : CFUUID = CFUUIDCreate(nil)
        let cfStr : CFString = CFUUIDCreateString(nil, uuid)
        
        let swiftString : String = cfStr as String
        return swiftString
    }
    
}
