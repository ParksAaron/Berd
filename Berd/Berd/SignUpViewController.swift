//
//  SignUpViewController.swift
//  Berd
//
//  Created by Aaron Parks on 11/18/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func validateFields() -> String? {
        if emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        let cleanedPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        let isValid = passwordTest.evaluate(with: cleanedPassword)
        if isValid == false {
            return "Please make sure your password is at least 8 characters, contains a special character, and a number."
        }
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let error = validateFields()
        if error != nil {
            showError(message: error!)
        }
        else{
            let firstName = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let username = usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil{
                    self.showError(message: "Error creating user.")
                }
                else{
                    let db = Firestore.firestore()
                    let reviewArray = [String]()
                    db.collection("Users").document(result!.user.uid).setData(["FirstName": firstName, "LastName": lastName, "Username": username, "Reviews":  reviewArray, "Friends": reviewArray, "PictureURL": "", "ID": result!.user.uid]) { (error) in
                        if error != nil {
                            self.showError(message: "Error saving user data.")
                        }
                    }
                }
                self.transitionToHome()
            }
        }
    }
    
    func showError(message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome(){
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeTableViewController
        let navigationController = UINavigationController(rootViewController: homeViewController!)
        view.window?.rootViewController = navigationController
        view.window?.makeKeyAndVisible()
    }
    
}
