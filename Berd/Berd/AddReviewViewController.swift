//
//  AddReviewViewController.swift
//  Berd
//
//  Created by Aaron Parks on 11/19/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class AddReviewViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var imagePickerController : UIImagePickerController!
    var myImage:UIImage?
    @IBOutlet weak var beerField: UITextField!
    @IBOutlet weak var breweryField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var ratingSelect: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func takePhoto(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = selectedImage
        myImage = selectedImage
        //dismiss(animated: true, completion: nil)
    }
    @IBAction func cameraRoll(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func reviewPost(_ sender: Any) {
        var beerID = ""
        let beer = beerField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let brewery = breweryField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let rating = ratingSelect.selectedSegmentIndex
        let db = Firestore.firestore()
        let breweryRef = db.collection("Breweries").document(brewery)
        let emptyArray = [String]()
        breweryRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            } else {
                db.collection("Breweries").document(brewery).setData(["BreweryName": brewery, "BeerIDs": emptyArray, "BeerNames": emptyArray, "Location": ""]) { (error) in
                    if error != nil {
                        self.showError(message: "Error saving brewery data.")
                    }
                }
            }
            let beerList = document?.get("BeerNames") as? Array<String> ?? emptyArray
            let beerIDs = document?.get("BeerIDs") as? Array<String> ?? emptyArray
            var counter = 0
            for beerName in beerList{

                if beerName == beer{
                    beerID = beerIDs[counter]
                }
                counter = counter + 1
            }
            if beerID == ""{
                breweryRef.updateData(["BeerNames": FieldValue.arrayUnion([beer])])
                beerID = db.collection("Beers").addDocument(data: ["Brewery": brewery, "Name": beer, "Reviews": emptyArray, "ABV": "", "IBU": "", "Type": ""]) { error in
                    if error != nil {
                        self.showError(message: "Error saving beer data")
                    }
                }.documentID
                
            }
            let now = Timestamp(date: Date())
            let reviewID = db.collection("Reviews").addDocument(data: ["BeerName": beer, "BeerID": beerID, "BreweryName": brewery, "Rating": rating, "Description": description, "Time": now, "UserID": Auth.auth().currentUser?.uid as Any]) { (error) in
                if error != nil {
                    self.showError(message: "Error saving review data.")
                }
            }.documentID
            let beerRef = db.collection("Beers").document(beerID)
            beerRef.updateData(["Reviews": FieldValue.arrayUnion([reviewID])])
            let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            userRef.updateData(["Reviews": FieldValue.arrayUnion([reviewID])])
            
            if self.myImage != nil {
                let storageRef = Storage.storage().reference().child("Reviews/\(reviewID)")
                guard let imageData = self.myImage!.jpegData(compressionQuality: 0.75) else { return
                }
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                storageRef.putData(imageData, metadata: metaData) { metaData, error in
                    if error == nil, metaData != nil {
                        print("success")
                        // success!
                    } else {
                        print("fail")
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showError(message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
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
