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
    private let tagServer = "eduid.server.pubID"
    private let tagSessionPub  = "eduid.session.pubID"
    private let tagSessionPriv = "eduid.session.privID"
    private let tagAppPub = "eduid.app.pubID"
    private let tagAppPriv = "eduid.app.privID"
    
    init() {
        resourcePath = ""
    }
    
    init(resourcePath : String){
        self.resourcePath = resourcePath
    }
    
    
    func changeResourcePath(path : String){
        self.resourcePath = path
        
    }
    
    
    
    
}

