//
//  CreateAccountViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/14/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse
import Foundation
import Crashlytics
import MobileCoreServices

class CreateAccountViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	
	var activityIndicator: UIActivityIndicatorView!
	var tutorBoolean: Bool! = false
	var subjectArray = ["English", "Math", "Sciences", "History"]
	var subjectName: String!
	
	@IBOutlet weak var firstNameField: UITextField!
	@IBOutlet weak var lastNameField: UITextField!
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var vPasswordField: UITextField!
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var tutorSwitch: UISwitch!
	@IBOutlet weak var subjectPicker: UIPickerView!
	
	override func viewDidAppear(animated: Bool) {
		PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig?, error: NSError?) -> Void in
			if error == nil {
				self.subjectArray = PFConfig.currentConfig().objectForKey("subjects") as! [String]
				self.tableView.reloadData()
				self.subjectPicker.reloadAllComponents()
			} else {
				Crashlytics.sharedInstance().recordError(error!)
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.subjectPicker.delegate = self
		self.firstNameField.delegate = self
		self.lastNameField.delegate = self
		self.emailField.delegate = self
		self.passwordField.delegate = self
		self.vPasswordField.delegate = self
		self.passwordField.secureTextEntry = true
		self.vPasswordField.secureTextEntry = true
		self.emailField.keyboardType = UIKeyboardType.EmailAddress
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.row == 6 && !tutorSwitch.on {
			return 0
		} else if indexPath.row == 6 && tutorSwitch.on {
			return 216
		}
		
		return 44
	}
	
	@IBAction func switchValueChanged(sender: UISwitch) {
		vPasswordField.resignFirstResponder()
		tableView.beginUpdates()
		tableView.endUpdates()
		
		if tutorSwitch.on {
			PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig?, error: NSError?) -> Void in
				if error == nil {
					self.subjectArray = config?["subjects"] as! [String]
					self.subjectPicker.reloadAllComponents()
				} else {
					Crashlytics.sharedInstance().recordError(error!)
				}
			}
			tutorBoolean = true
			tableView.rowHeight = 0
		} else {
			tutorBoolean = false
		}
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return self.subjectArray[row]
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return subjectArray.count
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		passwordField.resignFirstResponder()
		emailField.resignFirstResponder()
		firstNameField.resignFirstResponder()
		lastNameField.resignFirstResponder()
		vPasswordField.resignFirstResponder()
		return true
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		passwordField.resignFirstResponder()
		emailField.resignFirstResponder()
		firstNameField.resignFirstResponder()
		lastNameField.resignFirstResponder()
		vPasswordField.resignFirstResponder()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		subjectName = subjectArray[row]
	}
	
	@IBAction func signUpTapped(sender: AnyObject) {
		if tutorSwitch.on {
			tutorBoolean = true
		} else {
			tutorBoolean = false
		}
		
		let user = PFUser()
		user.username = emailField.text
		user["firstName"] = firstNameField.text
		user["lastName"] = lastNameField.text
		user["pWord"] = self.passwordField.text
		user.password = passwordField.text
		user.email = emailField.text
		user["tutor"] = tutorBoolean
		if tutorBoolean == true {
			user["subject"] = subjectName
		} else {
			user["available"] = false
		}
		
		let username = emailField.text
		let password = passwordField.text
		let email = emailField.text
		
		if passwordField.text != vPasswordField.text {
			let passwordMatch = UIAlertController(title: "Verify Password", message: "Your passwords do not match.", preferredStyle: UIAlertControllerStyle.Alert)
			passwordMatch.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(passwordMatch, animated: true, completion: nil)
		}
		if (username!.utf16.count < 4) {
			
			let alert = UIAlertView(title: "Username Invalid", message: "Username must be greater than 4 characters", delegate: self, cancelButtonTitle: "OK")
			alert.show()
		} else if (password!.utf16.count < 5) {
			let alert = UIAlertView(title: "Password Invalid", message: "Password must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
			alert.show()
		} else if email!.rangeOfString(".") == nil && email!.rangeOfString("@") == nil {
			let alert = UIAlertView(title: "Email Invalid", message: "Please enter a valid email.", delegate: self, cancelButtonTitle: "OK")
			alert.show()
		} else {
			activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
			activityIndicator.center = self.view.center
			activityIndicator.hidesWhenStopped = true
			activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
			view.addSubview(activityIndicator)
			activityIndicator.startAnimating()
			UIApplication.sharedApplication().beginIgnoringInteractionEvents()
			user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
				let installation:PFInstallation = PFInstallation.currentInstallation()
				installation.addUniqueObject("Group1", forKey: "channels")
				installation["user"] = PFUser.currentUser()
				
				installation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
					if error != nil {
						print(error?.localizedDescription)
					} else {

						print("Installation saved")
					}
				}
				
				if let error = error {
					Crashlytics.sharedInstance().recordError(error)
					if error.code == PFErrorCode.ErrorUsernameTaken.rawValue {
						let emptyView = UIAlertController(title: "Username Already Taken", message: "The username \(username) has already been taken.", preferredStyle: UIAlertControllerStyle.Alert)
						emptyView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
						self.presentViewController(emptyView, animated: true, completion: nil)
					}
					if error.code == PFErrorCode.ErrorUserEmailTaken.rawValue {
						let emptyView = UIAlertController(title: "Email Already Taken", message: "The email \(email) has already been taken.", preferredStyle: UIAlertControllerStyle.Alert)
						emptyView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
						self.presentViewController(emptyView, animated: true, completion: nil)
					}
				} else {
					// Hooray! Let them use the app now.
					self.performSegueWithIdentifier("GoToView2", sender: self)
					self.activityIndicator.stopAnimating()
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
				}
			}
		}
	}
}