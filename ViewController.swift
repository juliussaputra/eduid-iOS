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
         newData["cfg_value"] = "fake dragon rider"
         
         //model.save(data: newData)
         //model.fetch()
         //model.delete(name: "bully")
         //model.deleteAll()
        // model.fetch()
         let allData = model.getAll()
        */
         
 
        
        
        // TEST THE URL REQUEST
        
        let reqURL = URL(string: "https://eduid.htwchur.ch/oidc/.well-known/openid-configuration")
        //model.deleteAll()
        //model.fetchServer(serverUrl: reqURL!)
        //model.fetchDatabase()
        
//        requester.fetch(url: reqURL!, requestData: self.requestData)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
