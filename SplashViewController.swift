//
//  SplashViewController.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 11.01.18.
//  Copyright © 2018 Blended Learning Center. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var configModel : EduidConfigModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let reqUrl  = URL(string: "https://eduid.htwchur.ch/oidc/.well-known/openid-configuration")
        configModel = EduidConfigModel(serverUrl: reqUrl)
//        let storyboard = self.storyboard
//        let navigationController : UINavigationController = storyboard?.instantiateViewController(withIdentifier: "NController") as! UINavigationController
//        self.view.addSubview((navigationController.view)!)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideBusyUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showBusyUI()
        
        configModel?.deleteAll()
        configModel?.fetchServer()
        var timeoutCounter = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timerTmp in
            timeoutCounter += 1
            print(timeoutCounter)
            if (self.configModel?.configDownloaded)!  {
                timerTmp.invalidate()
                self.downloadFinished()
            } else if timeoutCounter == 5 {
                self.showAlertUI()
                timerTmp.invalidate()
            }
        }
        timer.fire()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    func downloadFinished () {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
//        self.storyboard.navi
        self.present(loginVC!, animated: true, completion: nil)
    }
    
    func showBusyUI() {
        self.activityIndicator.startAnimating()
        
    }
    
    func hideBusyUI() {
        self.activityIndicator.stopAnimating()
    }
    
    func showAlertUI(){
        
        let alert = UIAlertController(title: "Timeout", message: "Please check your internet connection and reopen the app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close App", style: .default, handler: { (alertAction) in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }

}
