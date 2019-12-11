//
//  ReviewDetailsViewController.swift
//  Berd
//
//  Created by Aaron Parks on 12/11/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ReviewDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBAction func commentButton(_ sender: Any) {
        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentViewController
        commentViewController.result = result
        commentViewController.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(commentViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let comments = result["Comments"] as! Array<DocumentReference>
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        let commentsRefs = result["Comments"] as! Array<DocumentReference>
        let commentID = commentsRefs[indexPath.row].documentID.trimmingCharacters(in: .whitespacesAndNewlines)
        let commentRef = db.collection("Comments").document(commentID)
        commentRef.getDocument { (document, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                cell.commentLabel.text = document?.get("Comment") as! String
                let userRef = document?.get("User") as! DocumentReference
                userRef.getDocument(completion: { (user, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                    }
                    else{
                        cell.usernameLabel.text = user?.get("Name") as! String
                        let userPicHttpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Users/" + (user!.get("ID") as! String))
                        userPicHttpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                            if let error = error{
                                cell.profileImageView.image = UIImage(named: "defaultpic")
                            }
                            else{
                                cell.profileImageView.image = UIImage(data: data!)
                            }
                        }
                        cell.profileImageView.layer.masksToBounds = true
                        cell.profileImageView.layer.cornerRadius = cell.profileImageView.bounds.width / 2
                    }
                })
            }
        }
        return cell
    }
    
    
    let db = Firestore.firestore()
    
    var result = [String:Any]()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var beerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reviewImageView: UIImageView!
    @IBOutlet weak var review1: UIImageView!
    @IBOutlet weak var review2: UIImageView!
    @IBOutlet weak var review3: UIImageView!
    @IBOutlet weak var review4: UIImageView!
    @IBOutlet weak var review5: UIImageView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        commentsTableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func setUpView(){
        beerLabel.text = (result["BeerName"] as! String) + " by " + (result["BreweryName"] as! String)
        descriptionLabel.text = result["Description"] as? String
        let httpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Reviews/" +
            (result["ID"] as! String))
        httpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            else{
                self.reviewImageView.image = UIImage(data: data!)
            }
        }
        let userRef = db.collection("Users").document(result["UserID"] as! String)
        userRef.getDocument{ (document, error) in
            if let document = document, document.exists {
                self.usernameLabel.text = document.get("Name") as? String
                let comments = document.get("Comments")
                if comments != nil{
                    //cell.commentButton.setTitle("View comments", for: .normal)
                }
                let userPicHttpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Users/" + (document.get("ID") as! String))
                userPicHttpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                    if let error = error{
                        self.profileImageView.image = UIImage(named: "defaultpic")
                    }
                    else{
                        self.profileImageView.image = UIImage(data: data!)
                    }
                }
            }
            else{
                print(error?.localizedDescription)
            }
            self.commentsTableView.reloadData()
        }
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        let review = result["Rating"] as! Int
        if review > 0{
            review2.image = UIImage(named: "beerfilled")
        }
        if review > 1{
            review3.image = UIImage(named: "beerfilled")
        }
        if review > 2{
            review4.image = UIImage(named: "beerfilled")
        }
        if review > 3{
            review5.image = UIImage(named: "beerfilled")
        }
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
