//
//  BrewDetailsViewController.swift
//  Berd
//
//  Created by Aaron Parks on 12/10/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit

import UIKit
import AlamofireImage
import Firebase
import FirebaseStorage
class BrewDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    let db = Firestore.firestore()
    var result: [String:Any]!
    var reviewArray = Array<String>()
    var classType = String()
    var reviewsArray = [NSDictionary]()
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "brewheaderID", for: indexPath) as! BrewDetailsCollectionReusableView
        header.brewName.text = result!["Name"] as! String
        if classType == "Breweries"{
            let userPicHttpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/" + classType + "/" + (result!["Name"] as! String))
            userPicHttpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                if let error = error{
                    header.imageView.image = UIImage(named: "background")
                }
                else{
                    header.imageView.image = UIImage(data: data!)
                }
            }
        }
        else{
            let userPicHttpsReference = Storage.storage().reference(forURL: "gs://berd-3a92b.appspot.com/" + classType + "/" + (result!["ID"] as! String))
            userPicHttpsReference.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                if let error = error{
                    header.imageView.image = UIImage(named: "background")
                }
                else{
                    header.imageView.image = UIImage(data: data!)
                }
            }
        }
        if classType == "Beers"{
            var review:Int = -1
            for reviewIt in reviewArray{
                let reviewRef = db.collection("Reviews").document(reviewIt)
                reviewRef.getDocument { (document, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                    }
                    else{
                        review = review + (document?.data()!["Rating"] as! Int)
                    }
                    if self.reviewArray.count != 0{
                        review = review / self.reviewArray.count
                        header.review1.image = UIImage(named: "beerfilled")
                        if review >= 0{
                            header.review2.image = UIImage(named: "beerfilled")
                        }
                        if review >= 1{
                            header.review3.image = UIImage(named: "beerfilled")
                        }
                        if review >= 2{
                            header.review4.image = UIImage(named: "beerfilled")
                        }
                        if review >= 3{
                            header.review5.image = UIImage(named: "beerfilled")
                        }
                    }
                }
            }
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reviewArray.count
    }
    
    func loadReviews(){
        if classType == "Breweries"{
            let currentUserRef = db.collection(classType).document(result!["Name"] as! String)
            currentUserRef.getDocument { (document, error) in
                if error != nil{
                    print(error?.localizedDescription)
                }
                else{
                    if self.classType == "Beers"{
                        self.reviewArray = document?.get("Reviews") as! Array<String>
                        self.collectionView.reloadData()
                    }
                    else{
                        for beer in document?.get("BeerIDs") as! Array<String>{
                            let beerGood = beer.trimmingCharacters(in: .whitespacesAndNewlines)
                            print(beerGood)
                            let beerRef = self.db.collection("Beers").document(beerGood)
                            beerRef.getDocument(completion: { (document2, error) in
                                if error != nil{
                                    print(error?.localizedDescription)
                                }
                                else{
                                    for review in document2?.get("Reviews") as! Array<String>{
                                        self.reviewArray.append(review)
                                    }
                                    self.collectionView.reloadData()
                                }
                            })
                        }
                    }
                    
                }
            }
        }
        else{
            let currentUserRef = db.collection(classType).document(result!["ID"] as! String)
            currentUserRef.getDocument { (document, error) in
                if error != nil{
                    print(error?.localizedDescription)
                }
                else{
                    if self.classType == "Beers"{
                        self.reviewArray = document?.get("Reviews") as! Array<String>
                        self.collectionView.reloadData()
                    }
                    else{
                        for beer in document?.get("BeerIDs") as! Array<String>{
                            let beerRef = self.db.collection("Beers").document(beer)
                            beerRef.getDocument(completion: { (document, error) in
                                if error != nil{
                                    print(error?.localizedDescription)
                                }
                                else{
                                    for review in document?.get("Reviews") as! Array<String>{
                                        self.reviewArray.append(review)
                                    }
                                    self.collectionView.reloadData()
                                }
                            })
                        }
                    }
                    
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
