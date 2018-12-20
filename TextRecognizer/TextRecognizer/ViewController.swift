//
//  ViewController.swift
//  TextRecognizer
//
//  Created by Narith Prak on 12/1/18.
//  Copyright © 2018 Narith Prak. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, G8TesseractDelegate {
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var textView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	func recognizeImageWithTesserat(image: UIImage) {
		guard let tesseract  = G8Tesseract(language: "eng+khm") else { return }
		tesseract.engineMode = .lstmOnly
		tesseract.pageSegmentationMode = .autoOnly
		tesseract.image = image
		tesseract.recognize()
		textView.text = tesseract.recognizedText
		activityIndicator.stopAnimating()
	}
	
	@IBAction func uploadImage(_ sender: Any) {
		presentImagePicker()
	}
	
	@IBAction func shared(_ sender: Any) {
		if textView.text.isEmpty {
			return
		}
		
		let activityViewController = UIActivityViewController(activityItems: [textView.text], applicationActivities: nil)
		let excludeActivities:[UIActivity.ActivityType] = [
		.assignToContact,
		.saveToCameraRoll,
		.addToReadingList]
		activityViewController.excludedActivityTypes = excludeActivities
		present(activityViewController, animated: true)
	}
	
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func presentImagePicker() {
		
		let imagePickerActionSheet = UIAlertController(title: "Upload Image",
																									 message: nil, preferredStyle: .actionSheet)
		
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			let cameraButton = UIAlertAction(title: "Take Photo",
																			 style: .default) { (alert) -> Void in
																				let imagePicker = UIImagePickerController()
																				imagePicker.delegate = self
																				imagePicker.sourceType = .camera
																				self.present(imagePicker, animated: true)
			}
			imagePickerActionSheet.addAction(cameraButton)
		}
		
		let libraryButton = UIAlertAction(title: "Choose Existing",
																			style: .default) { (alert) -> Void in
																				let imagePicker = UIImagePickerController()
																				imagePicker.delegate = self
																				imagePicker.sourceType = .photoLibrary
																				self.present(imagePicker, animated: true)
		}
		imagePickerActionSheet.addAction(libraryButton)
		
		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
		imagePickerActionSheet.addAction(cancelButton)
		
		present(imagePickerActionSheet, animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController,
														 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		
		if let selectedPhoto = info[.originalImage] as? UIImage,
			let scaledImage = selectedPhoto.scaleImage(640) {
			
			activityIndicator.startAnimating()
			
			dismiss(animated: true, completion: {
				self.recognizeImageWithTesserat(image: scaledImage)
			})
		}
	}
}

// MARK: - UIImage extension
extension UIImage {
	func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
		
		var scaledSize = CGSize(width: maxDimension, height: maxDimension)
		
		if size.width > size.height {
			let scaleFactor = size.height / size.width
			scaledSize.height = scaledSize.width * scaleFactor
		} else {
			let scaleFactor = size.width / size.height
			scaledSize.width = scaledSize.height * scaleFactor
		}
		
		UIGraphicsBeginImageContext(scaledSize)
		draw(in: CGRect(origin: .zero, size: scaledSize))
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return scaledImage
	}
}
