//
//  MasterViewController.swift
//  Assignment4
//
//  Created by Carly Dobie on 11/3/20.
//  Copyright © 2020 Carly Dobie. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    var detailViewController: DetailViewController? = nil
    var objects = [President]()
    var filteredObjects = [President]()

    let portraitStore = PortraitStore()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // Initialize and display search bar
        setUpSearchController()
        // Import plist data into table
//        readPropertyList()
        // Download JSON data
        downloadJSONData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    func setUpSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Presidents"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All", "Democrat", "Republican", "Whig"]
        searchController.delegate = self
        searchController.searchBar.delegate = self
    }
    
//    func readPropertyList() {
//        // Set path of the plist file to be imported
//        guard let path = Bundle.main.path(forResource: "presidents", ofType: "plist"), let xml = FileManager.default.contents(atPath: path) else {
//            fatalError("Unable to access property list")
//        }
//
//        do {
//            // Decode plist using President class
//            objects = try PropertyListDecoder().decode([President].self, from: xml)
//            // Sort presidents by their number
//            objects.sort {
//                return $0.number < $1.number
//            }
//        } catch {
//            fatalError("Unable to decode property list")
//        }
//
//    }
    
    func downloadJSONData() {
        guard let url = URL(string: "https://www.prismnet.com/~mcmahon/CS321/presidents.json") else {
            showAlert("Invalid URL for JSON data")
            return
        }
        
        weak var weakSelf = self
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            if httpResponse!.statusCode != 200 {
                weakSelf!.showAlert("HTTP Error: status code \(httpResponse!.statusCode)")
            } else if (data == nil && error != nil) {
                weakSelf!.showAlert("No data downloaded")
            } else {
                do {
                    weakSelf!.objects = try JSONDecoder().decode([President].self, from: data!)
                    // Sort by order of presidency
                    weakSelf!.objects.sort {
                        return $0.number < $1.number
                    }
                    
                    // Load data into table
                    DispatchQueue.main.async {
                        weakSelf!.tableView!.reloadData()
                    }
                    
                } catch {
                    weakSelf!.showAlert("Unable to decode JSON data")
                }
            }
        }
        task.resume()
    }
    
    // Search code
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // App "isFiltering" if searchController is active and if search bar
    // is not empty or search bar scope is filtering results
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    // Search function
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        // Filter presidents by scope (political party) or show all
        filteredObjects = objects.filter { president in
            let doesPartyMatch = (scope == "All") || (president.party == scope)
            
            // If nothing in search bar, show all presidents in scope
            if searchBarIsEmpty() {
                return doesPartyMatch
            } else {
                // If scope matches and president name matches, show result
                return doesPartyMatch && president.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Reload cells in table with search results
        tableView.reloadData()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let object: President
                if isFiltering() {
                    object = filteredObjects[indexPath.row]
                } else {
                    object = objects[indexPath.row]
                }
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.portraitStore = portraitStore
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows = number of all or number of search results
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredObjects.count
        } else {
            return objects.count
        }
    }

    // Display president name and party in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PresidentCell
        
        let object: President
        if isFiltering() {
            object = filteredObjects[indexPath.row]
        } else {
            object = objects[indexPath.row]
        }
        
        // Set president name and party in each cell of table
        cell.nameLabel!.text = object.name
        cell.partyLabel!.text = object.party
        
        return cell
    }

    // Editable cells
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Delete and insert cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Remove cell
        if editingStyle == .delete {
            if isFiltering() {
                let name = filteredObjects[indexPath.row].name
                let index = objects.firstIndex {
                    return $0.name == name
                }
                filteredObjects.remove(at: indexPath.row)
                objects.remove(at: index!)
            } else {
                objects.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // Update results according to search text and the selected scope
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
//    func searchBar(_ message: String) {
//        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//
//        DispatchQueue.main.async {
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // When memory is low, let system clear the image cache
    override func didReceiveMemoryWarning() {
        portraitStore.clearCache()
    }

}
