//
//  AutoInfoTableViewController.swift
//  AutoCatalog
//
//  Created by Uzver on 15.09.2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import CoreData

class AutoInfoTableViewController: UITableViewController {
	
	var imageIsChanged = false
	var currentAuto: AutoDataBase?
	
	// MARK: Outlet's
	
	@IBOutlet weak var saveButton: UIBarButtonItem!
	
	@IBOutlet weak var nameAutoField: UITextField!
	@IBOutlet weak var manufacturerField: UITextField!
	@IBOutlet weak var yearField: UITextField!
	@IBOutlet weak var carcaseField: UITextField!
	
	@IBOutlet weak var imageAuto: UIImageView!
	
	@IBAction func cancelAction(_ sender: Any) {
		dismiss(animated: true)
	}
	
	@IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
		var image: UIImage?
		
		if imageIsChanged {
			image = imageAuto.image
		} else {
			image = #imageLiteral(resourceName: "Photo")
		}
		if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
			let autoCatalog = AutoDataBase(context: context)
			autoCatalog.nameAuto = nameAutoField.text
			autoCatalog.yearAuto = yearField.text
			autoCatalog.manufacturerAuto = manufacturerField.text
			autoCatalog.carcaseAuto = carcaseField.text
			autoCatalog.imageAuto = image?.pngData()
			do {
				try context.save()
				print("Сохранение удалось!")
			} catch let error as NSError {
				print("Не удалось сохранить данные \(error), \(error.userInfo)")
			}
			performSegue(withIdentifier: "unwindSegueFromAutoInfo", sender: self)
		}
	}
	
	//MARK: View did load
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		saveButton.isEnabled = false
		
		nameAutoField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		manufacturerField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		yearField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		carcaseField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		editCell()
	}
	
	//MARK: Action sheet's
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 4 {
			let photoIcon = #imageLiteral(resourceName: "camera")
			let cameraIcon = #imageLiteral(resourceName: "camera")
			
			let chooseAction = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			
			let choosePhoto = UIAlertAction(title: "Photo", style: .default) { _ in
				self.chooseImage(source: .photoLibrary)
			}
			choosePhoto.setValue(photoIcon, forKey: "image")
			
			let chooseCamera = UIAlertAction(title: "Camera", style: .default) {_ in
				self.chooseImage(source: .camera)
			}
			chooseCamera.setValue(cameraIcon, forKey: "image")
			
			let chooseCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			
			chooseAction.addAction(choosePhoto)
			chooseAction.addAction(chooseCamera)
			chooseAction.addAction(chooseCancel)
			
			present(chooseAction, animated: true)
		} else {
			tableView.endEditing(true)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	//MARK: Edit Cell
	
	private func editCell() {
		guard let currentAuto = currentAuto else { return } 
			editNavigationBar()
			imageIsChanged = true
		guard let data = currentAuto.imageAuto, let image = UIImage(data: data) else { return }
			imageAuto.image = image
		nameAutoField.text = currentAuto.nameAuto
		yearField.text = currentAuto.yearAuto
		carcaseField.text = currentAuto.carcaseAuto
		manufacturerField.text = currentAuto.manufacturerAuto
	}
	
	//MARK: Navigation bar
	
	private func editNavigationBar() {
		if let topItem = navigationController?.navigationBar.topItem{
			topItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
		}
		navigationItem.leftBarButtonItem = nil
		title = currentAuto?.nameAuto
		saveButton.isEnabled = true
	}
}

//MARK: Extension: Choose image, image picker

extension AutoInfoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func chooseImage(source: UIImagePickerController.SourceType) {
		if UIImagePickerController.isSourceTypeAvailable(source) {
			let imagePicker = UIImagePickerController()
			imagePicker.allowsEditing = true
			imagePicker.delegate = self
			imagePicker.sourceType = source
			present(imagePicker, animated: true)
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		imageAuto.image = info[.editedImage] as? UIImage
		imageAuto.clipsToBounds = true
		imageIsChanged = true
		
		dismiss(animated: true)
	}
}

//MARK: Extension: Text field

extension AutoInfoTableViewController: UITextFieldDelegate{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	@objc func textFieldDidChange () {
		if nameAutoField.text?.isEmpty == true || yearField.text?.isEmpty == true || manufacturerField.text?.isEmpty == true {
			saveButton.isEnabled = false
		} else {
			saveButton.isEnabled = true
		}
	}
}
