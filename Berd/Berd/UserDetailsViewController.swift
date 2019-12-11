//
//  UserDetailsViewController.swift
//  Berd
//
//  Created by Aaron Parks on 11/24/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import AlamofireImage
import Firebase
import FirebaseStorage
class UserDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reviewArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! UserDetailsCollectionReusableView
        header.usernameLabel.text = result["Name"] as? String
        let userPicHttpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Users/" + (result["ID"] as? String ?? ""))
        userPicHttpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
            if let error = error{
                header.profileImage.image = UIImage(named: "defaultpic")
            }
            else{
                header.profileImage.image = UIImage(data: data!)
            }
        }
        header.profileImage.layer.masksToBounds = true
        header.profileImage.layer.cornerRadius = header.profileImage.bounds.width / 2
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userDetailsCollectionViewCell", for: indexPath) as! UserDetailsCollectionViewCell
        let reviewRef = db.collection("Reviews").document(reviewArray[indexPath.row])
        reviewRef.getDocument { (document, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                self.reviewsArray.insert((document?.data() as! NSDictionary), at: 0)
                let review = document?.data()!["Rating"] as! Int
                if review > 0{
                    cell.review2.image = UIImage(named: "beerfilled")
                }
                if review > 1{
                    cell.review3.image = UIImage(named: "beerfilled")
                }
                if review > 2{
                    cell.review4.image = UIImage(named: "beerfilled")
                }
                if review > 3{
                    cell.review5.image = UIImage(named: "beerfilled")
                }
                let httpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/Reviews/" + (document!["ID"] as! String))
                httpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    else{
                        cell.imageView.image = UIImage(data: data!)
                    }
                }
            }
        }
        return cell
    }
    

    let db = Firestore.firestore()
    var result = [String:Any]()
    var friended:Bool = false
    var passed:Bool = false
    var reviewsArray = [NSDictionary]()
    
    
    var reviewArray = Array<String>()
    
    var imagePickerController : UIImagePickerController!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var friendButton: UIBarButtonItem!
    @IBAction func friendButtonClicked(_ sender: Any) {
        if result != nil && (result["ID"] as! String) != Auth.auth().currentUser?.uid{
            let toBeFriended = !friended
            let userRef = db.collection("Users").document(result["ID"] as! String)
            let currentUserRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            if(toBeFriended){
                userRef.updateData(["Friends": FieldValue.arrayUnion([Auth.auth().currentUser?.uid])])
                currentUserRef.updateData(["Friends": FieldValue.arrayUnion([result["ID"]!])])
                self.setFriended(isFriended: true)
            }
            else{
                userRef.updateData(["Friends": FieldValue.arrayRemove([Auth.auth().currentUser?.uid])])
                currentUserRef.updateData(["Friends": FieldValue.arrayRemove([result["ID"]!])])
                self.setFriended(isFriended: false)
            }
        }
        else{
            imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if selectedImage != nil {
            let storageRef = Storage.storage().reference().child("Users/\(Auth.auth().currentUser!.uid)")
            guard let imageData = selectedImage!.jpegData(compressionQuality: 0.75) else { return
            }
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            storageRef.putData(imageData, metadata: metaData) { metaData, error in
                if error == nil, metaData != nil {
                    print("success")
                    self.collectionView.reloadData()
                } else {
                    print("fail")
                }
            }
        }
        //dismiss(animated: true, completion: nil)
    }
    
    func loadReviews(){
        if passed == false{
            let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            userRef.getDocument(completion: { (document, error) in
                if error != nil{
                    print(error?.localizedDescription)
                }
                else{
                    self.result = (document?.data())!
                    self.collectionView.reloadData()
                    let currentUserRef = self.db.collection("Users").document(self.result["ID"] as! String)
                    currentUserRef.getDocument { (document, error) in
                        if error != nil{
                            print(error?.localizedDescription)
                        }
                        else{
                            self.reviewArray = document?.get("Reviews") as! Array<String>
                            self.collectionView.reloadData()
                            
                        }
                    }                }
            })
        }
        else{
            let currentUserRef = db.collection("Users").document(result["ID"] as! String)
            currentUserRef.getDocument { (document, error) in
                if error != nil{
                    print(error?.localizedDescription)
                }
                else{
                    self.reviewArray = document?.get("Reviews") as! Array<String>
                    self.collectionView.reloadData()
                    
                }
            }
        }
    }
    
    func setFriended(isFriended:Bool){
        friended = isFriended
        let button  = UIButton(type: .custom)
        if (friended){
            if let image = UIImage(named:"removeuser") {
                button.setImage(image, for: .normal)
            }
        }
        else{
            if let image = UIImage(named:"adduser") {
                button.setImage(image, for: .normal)
            }
        }
        button.addTarget(self, action: #selector(self.friendButtonClicked(_:)), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func checkFriended(){
        let userRef = db.collection("Users").document(result["ID"] as! String)
        userRef.getDocument{ (document, error) in
            if let document = document, document.exists{
                //if user is in call setFriended with true, else false
                let friendList = document.get("Friends") as? Array<String> ?? [String]()
                if friendList.contains(Auth.auth().currentUser!.uid){
                    self.setFriended(isFriended: true)
                }
                else{
                    self.setFriended(isFriended: false)
                }
            }
            else{
                print(error?.localizedDescription)
            }
        }
    }
    
    func addCamera(){
        let button  = UIButton(type: .custom)
        if let image = UIImage(named: "camera"){
            button.setImage(image, for: .normal)
        }
        button.addTarget(self, action: #selector(self.friendButtonClicked(_:)), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if passed == true && (result["ID"] as! String) != Auth.auth().currentUser?.uid{
            self.checkFriended()
        }
        else{
            self.addCamera()
        }
        loadReviews()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)!
        let review = reviewsArray[indexPath.row]
        let reviewDetailsViewController = segue.destination as! ReviewDetailsViewController
        reviewDetailsViewController.result = review as! [String : Any]
    }
 

}
