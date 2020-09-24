//
//  MainTableViewController.swift
//  AutoCatalog
//
//  Created by Uzver on 15.09.2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
	
	
	let searchController = UISearchController(searchResultsController: nil)
	var autoDataBase: [AutoDataBase] = []
	var filteredAuto: [AutoDataBase] = []
	var fetchResultController: NSFetchedResultsController<AutoDataBase>!
	@IBAction func close(segue: UIStoryboardSegue) {
	}
	
	var searchBarIsEmpty: Bool {
		guard let text = searchController.searchBar.text else { return false }
		return text.isEmpty
	}
	
	var isFiltering: Bool {
		return searchController.isActive && !searchBarIsEmpty
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
			let fetchRequest: NSFetchRequest<AutoDataBase> = AutoDataBase.fetchRequest()
			do {
				autoDataBase = try context.fetch(fetchRequest)
			} catch let error as NSError {
				print(error.localizedDescription)
			}
		}
	}
	
	//MARK: View did load
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Тут найдешь ты искомое"
		navigationItem.searchController = searchController
		definesPresentationContext = true
		let fetchRequest: NSFetchRequest<AutoDataBase> = AutoDataBase.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "nameAuto", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		
		if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
			fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
			fetchResultController.delegate = self
			do {
				try fetchResultController.performFetch()
				autoDataBase = fetchResultController.fetchedObjects!
			} catch let error as NSError {
				print(error.localizedDescription)
			}
		}
	}
	
	//MARK: Controller
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert: guard let indexPath = newIndexPath else { break }
			tableView.insertRows(at: [indexPath], with: .fade)
		case .delete: guard let indexPath = indexPath else { break }
			tableView.deleteRows(at: [indexPath], with: .fade)
		case .update: guard let indexPath = indexPath else { break }
			tableView.reloadRows(at: [indexPath], with: .fade)
		default:
			tableView.reloadData()
		}
		autoDataBase = controller.fetchedObjects as! [AutoDataBase]
		tableView.reloadData()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
	
	//MARK: Search result's
	
	func updateSearchResults(for searchController: UISearchController) {
		filteredCars(searchText: searchController.searchBar.text!)
		tableView.reloadData()
	}
	
	private func filteredCars(searchText text: String) {
		filteredAuto = autoDataBase.filter { (autoDataBase) -> Bool in
			return (autoDataBase.nameAuto?.lowercased().contains(text.lowercased()))!
			
		}
	}
	
	//MARK: Properties ROW
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isFiltering {
			return filteredAuto.count
		}
		return autoDataBase.isEmpty ? 0 : autoDataBase.count
	}
	
	//MARK: Cell properties
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
		
		let newAutoAdd = isFiltering ? filteredAuto[indexPath.row] : autoDataBase[indexPath.row]
		
		cell.nameAuto.text = newAutoAdd.nameAuto
		cell.yearAuto.text = newAutoAdd.yearAuto
		
		cell.fotoAuto.image = UIImage(data: newAutoAdd.imageAuto!)
		cell.fotoAuto.layer.cornerRadius = cell.fotoAuto.frame.size.height / 2.5
		cell.fotoAuto.clipsToBounds = true
		
		return cell
	}
	
	//MARK: Delete button
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		var autoList = AutoDataBase()
		
		if isFiltering {
			autoList = filteredAuto[indexPath.row]
		} else {
			autoList = autoDataBase[indexPath.row]
		}
		let deleteAuto = UIContextualAction(style: .normal, title: "Удалить") {_, _, complete in
			
			if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
				let fetchRequest: NSFetchRequest<AutoDataBase> = AutoDataBase.fetchRequest()
				if let autos = try? context.fetch(fetchRequest) {
					for _ in autos {
						context.delete(autoList)
					}
				}
				do {
					try context.save()
					
				} catch {
					print(error.localizedDescription)
				}
			}
			complete(true)
		}
		deleteAuto.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
		let action = UISwipeActionsConfiguration(actions: [deleteAuto])
		return action
	}
	
	//MARK: Segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			guard let indexPath = tableView.indexPathForSelectedRow else { return }
			let auto = isFiltering ? filteredAuto[indexPath.row] :  autoDataBase[indexPath.row]
			let newAutoVC = segue.destination as! AutoInfoTableViewController
			newAutoVC.currentAuto = auto
			tableView.reloadData()
		}
	}
}

//MARK: Extension search bar

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

