//
//  SearchTableViewController.swift
//  Berd
//
//  Created by Aaron Parks on 11/24/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet var searchTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var resultsArray = [NSDictionary?]()
    var filteredArray = [NSDictionary?]()
    let scopeArray = ["Users", "Beers", "Breweries"]
    
    let databaseRef = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.searchBar.scopeButtonTitles = scopeArray
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView  = searchController.searchBar
        let scope = searchController.searchBar.selectedScopeButtonIndex
        databaseRef.collection(scopeArray[scope]).getDocuments(){
            (querySnapshot, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                for document in querySnapshot!.documents{
                    self.resultsArray.append(document.data() as NSDictionary)
                     self.searchTableView.insertRows(at: [IndexPath(row: self.resultsArray.count - 1, section: 0)], with: UITableView.RowAnimation.automatic)
                }
            }
        }

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
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredArray.count
        }
        else{
            return self.resultsArray.count
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func filterContent(searchText:String){
        self.filteredArray = self.resultsArray.filter{result in
            let name = result!["Name"] as? String
            return(name?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        let result : NSDictionary?
        if searchController.isActive && searchController.searchBar.text != ""{
            result = filteredArray[indexPath.row]
        }
        else{
            result = self.resultsArray[indexPath.row]
        }
        cell.textLabel?.text = result?["Name"] as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scope = searchController.searchBar.selectedScopeButtonIndex
        var result: [String:Any]
        if searchController.isActive && searchController.searchBar.text != ""{
            result = filteredArray[indexPath.row] as! [String : Any]
        }
        else{
            result = self.resultsArray[indexPath.row] as! [String : Any]
        }
        if scopeArray[scope] == "Beers"{
            let beerDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BrewDetailsVC") as! BrewDetailsViewController
            beerDetailsViewController.classType = "Beers"
            beerDetailsViewController.result = result as! [String:Any]
            self.navigationController?.pushViewController(beerDetailsViewController, animated: true)
        }
        else if scopeArray[scope] == "Breweries"{
            let breweryDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BrewDetailsVC") as! BrewDetailsViewController
            breweryDetailsViewController.classType = "Breweries"
            breweryDetailsViewController.result = result as! [String:Any]
            self.navigationController?.pushViewController(breweryDetailsViewController, animated: true)
        }
        else{
            let userDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsVC") as! UserDetailsViewController
            userDetailsViewController.result = result as! [String:Any]
            userDetailsViewController.passed = true
            self.navigationController?.pushViewController(userDetailsViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.resultsArray.removeAll()
        tableView.reloadData()
        let scope = searchController.searchBar.selectedScopeButtonIndex
        databaseRef.collection(scopeArray[scope]).getDocuments(){
            (querySnapshot, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                for document in querySnapshot!.documents{
                    self.resultsArray.append(document.data() as NSDictionary)
                    self.searchTableView.insertRows(at: [IndexPath(row: self.resultsArray.count - 1, section: 0)], with: UITableView.RowAnimation.automatic)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
