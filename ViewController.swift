//
//  ViewController.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var model = EduidConfigModel()
    private var requestData = RequestData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did load")
        /*
         var newData : [String : String] = [:]
         newData["cfg_name"] = "bully"
         newData["cfg_value"] = "00000"
         
         //        newData.setValue("blabla", forKey: "cfg_name")
         //        newData.setValue("123455", forKey: "cfg_value")
         //model.save(data: newData)
         model.fetch()
         model.delete(name: "budi")
         //model.deleteAll()
         model.fetch()
         let allData = model.getAll()
         print(allData[0].allKeys)
         for key in allData[0].allKeys{
         
         print(" inf for key at 0 :" , key as! String)
         }
         
         */
        
        
        // TEST THE URL REQUEST
        let requester = OAuthRequester.init()
        let reqURL = URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/hot-tracks/all/10/explicit.json")
        requester.fetch(url: reqURL!, requestData: self.requestData)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
