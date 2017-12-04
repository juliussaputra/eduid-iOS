//
//  EduidConfigModel.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class EduidConfigModel : NSObject {
    
    private var entities : [NSManagedObject] = []
    //    private lazy var appDelegate: AppDelegate? = nil
    private lazy var persistentContainer : NSPersistentContainer? = nil
    private lazy var managedContext: NSManagedObjectContext? = nil
    private var jsonDict: [String : Any]?
    
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
    //private var grantSupported : Bool?
    
    override init() {
        super.init()
        //        self.appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        self.persistentContainer = createContainer()
        self.managedContext = persistentContainer?.viewContext
        defer{ self.fetchDatabase() }
    }
    
    
    private func createContainer () -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "eduid_iOS")
        let storeUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.htwchur.eduid.share")?.appendingPathComponent("eduid_iOS.sqlite")
        print(storeUrl?.absoluteString ?? "no url for container found" )
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = storeUrl
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeUrl!)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error) , \(error.userInfo)")
            }
        })
        return container
    }
    
    func delete(name : String) {
        let indexHelper = searchData(name: name)
        if indexHelper.count <= 0{
            return
        }
        for i in indexHelper{
            
            do {
                managedContext?.delete(entities[i] as NSManagedObject)
                try managedContext?.save()
            }catch let error as NSError{
                print("Error on deleting request. \(error)  : \(error.userInfo)")
            }
            
        }
    }
    
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EduidConfiguration")
        let req = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do{
            try managedContext?.execute(req)
            try managedContext?.save()
        }catch let error as NSError {
            print("Delete Failed : \(error) , \(error.userInfo)")
        }
    }
    
    func extractingJson (){
        
        self.issuer = jsonDict?["issuer"] as? String
        self.auth = URL(string: jsonDict?["authorization_endpoint"] as! String)
        self.endSession = URL(string: jsonDict?["end_session_endpoint"] as! String)
        self.userInfo = URL(string: jsonDict?["userinfo_endpoint"] as! String)
        self.introspection = URL(string: jsonDict?["introspection_endpoint"] as! String)
        self.token = URL(string: jsonDict?["token_endpoint"] as! String)
        self.revocation = URL(string: jsonDict?["revocation_endpoint"] as! String)
        self.jwksUri = URL(string: jsonDict?["jwks_uri"] as! String)
        
    }
    
    func extractDatabaseData(savedData : NSManagedObject){
        self.issuer = savedData.value(forKey: "issuer") as? String
        self.auth = URL(string: savedData.value(forKey: "auth") as! String)
        self.endSession = URL(string: savedData.value(forKey:"endSession") as! String)
        self.userInfo = URL(string: savedData.value(forKey: "userInfo") as! String)
        self.introspection = URL(string: savedData.value(forKey: "introspection") as! String)
        self.token = URL(string: savedData.value(forKey: "token") as! String)
        self.revocation = URL(string: savedData.value(forKey: "revocation") as! String)
        self.jwksUri = URL(string: savedData.value(forKey: "jwksUri") as! String)
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
            entities = (try managedContext?.fetch(fetchRequest))!
        } catch let error as NSError {
            print("Couldn't fetch the data. \(error), \(error.userInfo)")
        }
        print("FETCHED : " , self.entities.count )
        //assuming there is just one config data in core data
        if(entities.count > 0) {
            let entity = entities.first
            extractDatabaseData(savedData: entity!)
        }
        
    }
    
    //Fetch some specific data from core data
    func fetchDatabase(withFilter name: String ){
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: "EduidConfiguration")
        fetchRequest.predicate = NSPredicate(format: "cfg_name == %@", name)
        do{
            entities = (try managedContext?.fetch(fetchRequest))!
        } catch let error as NSError {
            print("Couldn't fetch the data. \(error), \(error.userInfo)")
        }
        
    }
    
    func getAll() -> [NSDictionary] {
        if entities.count == 0 {return []}
        //print("in get all : ", eduidConfigData.count)
        
        var configArray = [NSMutableDictionary]()
        
        for i in 0 ..< entities.count {
            //print("in for")
            let config = entities[i]
            let entityDesc = config.entity
            let attributes = entityDesc.attributesByName
            
            let dictConfig = NSMutableDictionary()
            
            for attributeName in attributes.keys {
                //print("in second for")
                let tmpValue = config.value(forKey: attributeName)
                dictConfig.setValue(tmpValue, forKey: attributeName)
                //                print(dictConfig.value(forKey: attributeName)!);
            }
            //print("dictConfig : ", dictConfig.count)
            configArray.append(dictConfig)
        }
        //print("ENDE : " , configArray.count)
        return configArray
        
    }
    
    
    
    func printAllData () {
        for confData in entities{
            //print("printALL")
            let entityDesc = confData.entity
            let keys = entityDesc.attributesByName
            
            for key in keys.keys {
                print("Printing Data , key : ",  key , " , value :" , confData.value(forKey: key))
            }
        }
    }
    
    func save(){ //(data : [String : String] ){
        
        let entity = NSEntityDescription.entity(forEntityName: "EduidConfiguration", in: managedContext!) as NSEntityDescription!
        let configData = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        configData.setValue(auth?.absoluteString, forKey: "auth")
        configData.setValue(endSession?.absoluteString, forKey: "endSession")
        configData.setValue(introspection?.absoluteString, forKey: "introspection")
        configData.setValue(issuer, forKey: "issuer")
        configData.setValue(jwksUri?.absoluteString, forKey: "jwksUri")
        configData.setValue(revocation?.absoluteString, forKey: "revocation")
        configData.setValue(token?.absoluteString, forKey: "token")
        configData.setValue(userInfo?.absoluteString, forKey: "userInfo")
        
        do{
            try managedContext!.save()
            print("SAVED")
        } catch let error as NSError {
            print("Couldn't save the data. \(error), \(error.userInfo)")
        }
    }
    
    
    func searchData(name : String) -> [Int] {
        var result : [Int] = []
        
        for i in 0 ..< entities.count {
            let configData = entities[i]
            //print("search DATA : " , configData.value(forKey: "cfg_name") )
            //print("in search data " , configData.entity.propertiesByName.keys.contains(name))
            if configData.value(forKey: "cfg_name") as! String == name {
                result.append(i)
            }
            continue
        }
        
        return result
    }
    
    
    
    
    
}

extension EduidConfigModel : URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        let httpResponse = dataTask.response as! HTTPURLResponse
        print("Did Receive Response with Status: " , httpResponse.statusCode)
        if(httpResponse.statusCode != 200){
            return
        }
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("Did receive data , data length: " , data.count)
        
        do{
            jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        } catch{
            print(error)
            return
        }
        print(jsonDict!)
        let supportedTypes = jsonDict!["grant_types_supported"] as! [String]
        for type in supportedTypes{
            //print(type , " contain bearer : " , type.contains("jwt-bearer"))
            if type.contains("jwt-bearer") {
                extractingJson()
                save()
            }
        }
    }
}
