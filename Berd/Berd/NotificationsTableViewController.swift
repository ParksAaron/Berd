//
//  NotificationsTableViewController.swift
//  Berd
//
//  Created by Aaron Parks on 12/10/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class NotificationsTableViewController: UITableViewController {
    
    let databaseRef = Firestore.firestore()
    var commentsArray = [NSDictionary]()
    var reviewArray = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadComments()

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
        return commentsArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! NotificationsTableViewCell
        let userRef = self.commentsArray[indexPath.row]["User"] as! DocumentReference
        userRef.getDocument { (document, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                cell.usernameLabel.text = document?.get("Name") as! String
                let userPicHttpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Users/" + (document!.get("ID") as! String))
                userPicHttpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                    if let error = error{
                        cell.profilePictureView.image = UIImage(named: "defaultpic")
                    }
                    else{
                        cell.profilePictureView.image = UIImage(data: data!)
                    }
                }
                cell.profilePictureView.layer.masksToBounds = true
                cell.profilePictureView.layer.cornerRadius = cell.profilePictureView.bounds.width / 2
            }
        }
        let reviewRef = self.commentsArray[indexPath.row]["Review"] as! DocumentReference
        reviewRef.getDocument { (document, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                self.reviewArray.insert((document?.data() as! NSDictionary), at: 0)
                let reviewPicHttpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Reviews/" + (document!.get("ID") as! String))
                reviewPicHttpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                    if let error = error{
                        cell.postPictureView.image = UIImage(named: "defaultpic")
                    }
                    else{
                        cell.postPictureView.image = UIImage(data: data!)
                    }
                }
            }
        }
        cell.descriptionLabel.text = "Commented on your post."

        // Configure the cell...

        return cell
    }
    
    func loadComments(){
        let userRef = databaseRef.collection("Users").document(Auth.auth().currentUser!.uid)
        var reviewsArray = Array<String>()
        let user = userRef.getDocument { (document, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                reviewsArray = document?.get("Reviews") as! [String]
                let commentsRef = self.databaseRef.collection("Comments")
                let reviewsRef = self.databaseRef.collection("Reviews")
                for review in reviewsArray{
                    let reviewRef = reviewsRef.document(review)
                    let query = commentsRef.whereField("Review", isEqualTo: reviewRef)
                    query.getDocuments { (documents, error) in
                        if error != nil{
                            print(error?.localizedDescription)
                        }
                        else{
                            for documentIt in documents!.documents{
                                if documentIt.get("User") as! DocumentReference != userRef{
                                    self.commentsArray.append(documentIt.data() as NSDictionary)
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
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
