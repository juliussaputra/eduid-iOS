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
    
    private var value : String?
    private var name : String?
    private var eduidConfigData : [NSManagedObject] = []
    private lazy var appDelegate: AppDelegate? = nil
    private lazy var managedContext: NSManagedObjectContext? = nil
    
    override init() {
        super.init()
        
        self.appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        self.managedContext = appDelegate?.persistentContainer.viewContext
    }
    
    func save(data : [String : String] ){
        
        let entity = NSEntityDescription.entity(forEntityName: "EduidConfig", in: managedContext!) as NSEntityDescription!
        let configData = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        configData.setValue(data["cfg_name"], forKey: "cfg_name")
        configData.setValue(data["cfg_value"], forKey: "cfg_value")
        
        do{
            try managedContext!.save()
            print("SAVED")
        } catch let error as NSError {
            print("Couldn't save the data. \(error), \(error.userInfo)")
        }
    }
    
    
    func fetch(){
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: "EduidConfig")
        do{
            eduidConfigData = (try managedContext?.fetch(fetchRequest))!
        } catch let error as NSError {
            print("Couldn't fetch the data. \(error), \(error.userInfo)")
        }
        
        print("FETCHED : " , self.eduidConfigData.count )
        self.printAllData()
        
    }
    
    func fetch(withFilter name: String ){
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: "EduidConfig")
        fetchRequest.predicate = NSPredicate(format: "cfg_name == %@", name)
        do{
            eduidConfigData = (try managedContext?.fetch(fetchRequest))!
        } catch let error as NSError {
            print("Couldn't fetch the data. \(error), \(error.userInfo)")
        }
        
    }
    
    func getAll() -> [NSDictionary] {
        if eduidConfigData.count == 0 {return []}
        //print("in get all : ", eduidConfigData.count)
        
        var configArray = [NSMutableDictionary]()
        
        for i in 0 ..< eduidConfigData.count {
            //print("in for")
            let config = eduidConfigData[i]
            let entityDesc = config.entity
            let attributes = entityDesc.attributesByName
            
            let dictConfig = NSMutableDictionary()
            
            for attributeName in attributes.keys {
                //print("in second for")
                let tmpValue = config.value(forKey: attributeName)
                dictConfig.setValue(tmpValue, forKey: attributeName)
                print(dictConfig.value(forKey: attributeName));
            }
            //print("dictConfig : ", dictConfig.count)
            configArray.append(dictConfig)
        }
        print("ENDE : " , configArray.count)
        return configArray
        
    }
    
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EduidConfig")
        var req = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do{
            try managedContext?.execute(req)
            try managedContext?.save()
        }catch let error as NSError {
            print("Delete Failed : \(error) , \(error.userInfo)")
        }
    }
    
    func delete(name : String) {
        let indexHelper = searchData(name: name)
        if indexHelper.count <= 0{
            return
        }
        for i in indexHelper{
            
            do {
                managedContext?.delete(eduidConfigData[i] as NSManagedObject)
                try managedContext?.save()
            }catch let error as NSError{
                print("Error on deleting request. \(error)  : \(error.userInfo)")
            }
            
        }
        
    }
    
    func searchData(name : String) -> [Int] {
        var result : [Int] = []
        
        for i in 0 ..< eduidConfigData.count {
            let configData = eduidConfigData[i]
            if configData.entity.propertiesByName.index(forKey: name) != nil {
                result.append(i)
            }
            continue
        }
        
        return result
    }
    
    func printAllData () {
        for confData in eduidConfigData{
            print("printALL")
            let entityDesc = confData.entity
            let keys = entityDesc.attributesByName
            
            for key in keys.keys {
                print ("all2")
                print("Data , key : ",  key , " , value :" , confData.value(forKey: key)!)
            }
        }
    }
    
}
