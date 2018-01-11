//
//  ProfileViewController.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 11.01.18.
//  Copyright © 2018 Blended Learning Center. All rights reserved.
//

import UIKit
import JWTswift

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileLabel: UILabel!
    
    var textLabel : String?
    var token : TokenModel?
    var id_Token : [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if token == nil {
            print("TOKEN IS NIL")
        }
        
        id_Token = (token?.giveIdTokenJWS())!
        
        profileLabel.text = textLabel!
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TAPPED row : \(indexPath.count)")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value2, reuseIdentifier: "cell")
        cell.textLabel?.text = "AA"
        cell.detailTextLabel?.text = "BB"
        
        return cell
    }
    
}
