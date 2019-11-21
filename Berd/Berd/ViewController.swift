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
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeTableViewController
        let navigationController = UINavigationController(rootViewController: homeViewController!)
        view.window?.rootViewController = navigationController
        view.window?.makeKeyAndVisible()
    }


}

