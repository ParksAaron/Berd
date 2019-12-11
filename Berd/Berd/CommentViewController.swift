//
//  CommentViewController.swift
//  Berd
//
//  Created by Aaron Parks on 12/11/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class CommentViewController: UIViewController {

    let db = Firestore.firestore()
    var result = [String:Any]()
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if commentField.text != ""{
            let comment = commentField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let reviewRef = db.collection("Reviews").document(result["ID"] as! String)
            let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            let commentRef = db.collection("Comments").addDocument(data: ["Comment": comment, "User": userRef, "Review": reviewRef])
            reviewRef.updateData(["Comments" : FieldValue.arrayUnion([commentRef as! Any])])
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
    @IBOutlet weak var commentField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        commentField.becomeFirstResponder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
