//
//  EduidConfig.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class EduidConfig : NSObject {
    
    private lazy var appDelegate : AppDelegate? = nil
    private lazy var managedContext : NSManagedObjectContext? = nil
    
    private var json: [String : Any]?
    
    private var issuer : String?
    
    //Endpoints
    private var auth : URL?
    private var endSession : URL?
    private var userInfo : URL?
    private var introspection : URL?
    private var token : URL?
    private var revocation : URL?
    
    //jwks URI
    private var jwksUri : URL?
    //Additional Data
    private var claims : [String]?
    private var grantSupported : Bool?
    
    private var entityData : NSManagedObject?
    
    
    override init(){
        super.init()
        self.appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        self.managedContext = appDelegate?.persistentContainer.viewContext
        defer{ self.fetchDatabase() }
    }
        
    //Fetch config data from the EDU-ID Server
    func fetchServer(serverUrl : URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let dataTask = session.dataTask(with: serverUrl)
        dataTask.resume()
    }
    
    //Fetch data from core data, usually used at the begining
    func fetchDatabase(){
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: "EduidConfiguration")
        do{
            let entities = try managedContext?.fetch(fetchRequest)
            if entities?.count == 1 {
                entityData =  entities?.first
            } else {
                print("entities data = " )
                return
            }
        } catch let error as NSError {
            print("Couldn't fetch the data. \(error), \(error.userInfo)")
        }
        
       // print("FETCHED : " , self.eduidConfigData.count )
       // self.printAllData()
        
    }
    
}

extension EduidConfig : URLSessionDataDelegate {
    
}
