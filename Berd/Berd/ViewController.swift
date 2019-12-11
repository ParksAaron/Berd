//
//  ViewController.swift
//  Berd
//
//  Created by Aaron Parks on 10/23/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil{
            self.transitionToHome()
        }
    }
    
    func transitionToHome(){
        let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
        self.view.window?.rootViewController = tabBarController
        self.view.window?.makeKeyAndVisible()
    }
}

