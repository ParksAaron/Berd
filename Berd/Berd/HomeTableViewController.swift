//
//  HomeTableViewController.swift
//  Berd
//
//  Created by Aaron Parks on 11/19/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class HomeTableViewController: UITableViewController {
    @IBAction func addReviewClicked(_ sender: Any) {
        let addReviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewViewController
        self.navigationController?.pushViewController(addReviewViewController, animated: true)
    }
    
    let databaseRef = Database.database().reference()
    let db = Firestore.firestore()
    var reviewArray = [NSDictionary]()
    var reviewIDArray = Array<String>()
    var friendArray = Array<String>()
    var numberOfReviews: Int!
    
    func loadReviews(){
        let currentUserRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        currentUserRef.getDocument{ (document, error) in
            if let document = document, document.exists{
                self.friendArray = document.get("Friends") as! [String]
                let reviewsRef = self.db.collection("Reviews")
                reviewsRef.getDocuments(completion: { (snapshot, errir) in
                    if snapshot!.isEmpty{
                        self.numberOfReviews = 0
                    }
                    else{
                        self.reviewArray.removeAll()
                        for document in snapshot!.documents{
                            for friend in self.friendArray{
                                if document["UserID"] as! String == friend{
                                    self.reviewArray.append(document.data() as NSDictionary)
                                    self.reviewIDArray.append(document.documentID)
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                })
            }
            else{
                print(error?.localizedDescription)
            }
        }
    }

    @IBAction func onLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let initViewController = self.storyboard?.instantiateViewController(withIdentifier: "InitVC") as? ViewController
            let navigationController = UINavigationController(rootViewController: initViewController!)
            self.view.window?.rootViewController = navigationController
            self.view.window?.makeKeyAndVisible()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadReviews()
        let logo = UIImage(named: "logonobeer")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reviewArray.count
    }
    
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedTableViewCell", for: indexPath) as! feedTableViewCell
        cell.nameLabel.text = (self.reviewArray[indexPath.row]["BeerName"] as! String) + " by " + (self.reviewArray[indexPath.row]["BreweryName"] as! String)
        cell.descriptionLabel.text = self.reviewArray[indexPath.row]["Description"] as? String
        let httpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Reviews/" + self.reviewIDArray[indexPath.row])
        httpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            else{
                cell.pictureView.image = UIImage(data: data!)
            }
        }
        let userRef = self.db.collection("Users").document(reviewArray[indexPath.row]["UserID"] as! String)
        userRef.getDocument{ (document, error) in
            if let document = document, document.exists {
                cell.userName.text = document.get("Name") as? String
                let comments = document.get("Comments")
                print(comments)
                if comments != nil{
                    cell.commentButton.setTitle("View comments", for: .normal)
                }
                let userPicHttpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Users/" + (document.get("ID") as! String))
                userPicHttpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                    if let error = error{
                        cell.profileImageView.image = UIImage(named: "defaultpic")
                    }
                    else{
                        cell.profileImageView.image = UIImage(data: data!)
                    }
                }
            }
            else{
                print(error?.localizedDescription)
            }
        }
        cell.profileImageView.layer.masksToBounds = true
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.bounds.width / 2
        let review = self.reviewArray[indexPath.row]["Rating"] as! Int
        if review > 0{
            cell.rating2.image = UIImage(named: "beerfilled")
        }
        if review > 1{
            cell.rating3.image = UIImage(named: "beerfilled")
        }
        if review > 2{
            cell.rating4.image = UIImage(named: "beerfilled")
        }
        if review > 3{
            cell.rating5.image = UIImage(named: "beerfilled")
        }
        return cell
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let review = reviewArray[indexPath.row]
        let reviewDetailsViewController = segue.destination as! ReviewDetailsViewController
        reviewDetailsViewController.result = review as! [String : Any]
    }


}
