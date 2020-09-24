//
//  AutoInfoTableViewController.swift
//  AutoCatalog
//
//  Created by Uzver on 15.09.2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

class AutoInfoTableViewController: UITableViewController {
	//MARK: Outlet/Action
	var imageIsChanged = false
	var currentAuto: AutoDB?
	
	@IBAction func cancelAction(_ sender: Any) {
		dismiss(animated: true)
	}
	
	@IBOutlet weak var saveButton: UIBarButtonItem!
	
	@IBOutlet weak var nameAutoField: UITextField!
	@IBOutlet weak var manufacturerField: UITextField!
	@IBOutlet weak var yearField: UITextField!
	@IBOutlet weak var carcaseField: UITextField!
	
	@IBOutlet weak var imageAuto: UIImageView!
	
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
	
	//MARK: Action Sheet
	
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
	
	//MARK: Save Auto
	
	func saveAuto() {
		var image: UIImage?
		
		if imageIsChanged {
			image = imageAuto.image
		} else {
			image = #imageLiteral(resourceName: "Photo")
		}
		
		let imageAuto = image?.pngData()
		let newAuto = AutoDB(nameAuto: nameAutoField.text!, yearAuto: yearField.text, imageAuto: imageAuto, carcaseAuto: carcaseField.text, manufacturerAuto: manufacturerField.text)
		
		if currentAuto != nil {
			try! realm.write() {
				currentAuto?.nameAuto = newAuto.nameAuto
				currentAuto?.yearAuto = newAuto.yearAuto
				currentAuto?.imageAuto = newAuto.imageAuto
				currentAuto?.carcaseAuto = newAuto.carcaseAuto
				currentAuto?.manufacturerAuto = newAuto.manufacturerAuto
			}
		} else {
			SaveManager.saveObject(newAuto)
		}
	}
	
	//MARK: Edit Cell
	
	private func editCell() {
		if currentAuto != nil {
			editNavigationBar()
			imageIsChanged = true
			guard let data = currentAuto?.imageAuto, let image = UIImage(data: data) else { return }
			imageAuto.image = image
			nameAutoField.text = currentAuto?.nameAuto
			yearField.text = currentAuto?.yearAuto
			carcaseField.text = currentAuto?.carcaseAuto
			manufacturerField.text = currentAuto?.manufacturerAuto
		}
	}
	
	//MARK: Navigation Bar
	
	private func editNavigationBar() {
		if let topItem = navigationController?.navigationBar.topItem{
			topItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
		}
		navigationItem.leftBarButtonItem = nil
		title = currentAuto?.nameAuto
		saveButton.isEnabled = true
	}
}

//MARK: Extension Image

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

//MARK: Extension textField

extension AutoInfoTableViewController: UITextFieldDelegate{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	@objc func textFieldDidChange () {
		if nameAutoField.text?.isEmpty == true ||
			yearField.text?.isEmpty == true ||
			manufacturerField.text?.isEmpty == true {
			saveButton.isEnabled = false
		} else {
			saveButton.isEnabled = true
		}
	}
}
