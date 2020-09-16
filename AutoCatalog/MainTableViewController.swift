//
//  MainTableViewController.swift
//  AutoCatalog
//
//  Created by Uzver on 15.09.2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import RealmSwift

class MainTableViewController: UITableViewController, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
    
    private var autoDataBase: Results<AutoDataBase>!
    private var filteredAuto: Results<AutoDataBase>!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoDataBase = realm.objects(AutoDataBase.self)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Тут найдешь ты искомое"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoDataBase.isEmpty ? 0 : autoDataBase.count
      }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let newAutoAdd = autoDataBase[indexPath.row]
        
        cell.nameAuto.text = newAutoAdd.nameAuto
        cell.yearAuto.text = newAutoAdd.yearAuto
        
        cell.fotoAuto.image = UIImage(data: newAutoAdd.imageAuto!)
        cell.fotoAuto.layer.cornerRadius = cell.fotoAuto.frame.size.height / 2.5
        cell.fotoAuto.clipsToBounds = true
        
        return cell
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let auto: AutoDataBase
            if isFiltering {
                auto = filteredAuto[indexPath.row]
            } else {
                auto = autoDataBase[indexPath.row]
            }
            let newAutoVC = segue.destination as! AutoInfoTableViewController
            newAutoVC.currentAuto = auto
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newautoVC = segue.source as? AutoInfoTableViewController else { return }
        newautoVC.savePlace()
        tableView.reloadData()
    }
}



extension MainTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            navigationController?.hidesBarsOnSwipe = false
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        navigationController?.hidesBarsOnSwipe = true
    }
}
