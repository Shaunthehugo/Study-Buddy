//
//  SignInViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/14/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse
import Crashlytics

class SignInViewController: UITableViewController, UITextFieldDelegate {
	
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var forgotButton: UIButton!
	@IBOutlet weak var createAccountButton: UIButton!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var logoView: UIImageView!

	var emailTextField: UITextField!
	var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.emailField.delegate = self
		self.passwordField.delegate = self
		passwordField.secureTextEntry = true
		
		// Do any additional setup after loading the view.
		self.logoView.alpha = 0.0
		UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.logoView.alpha = 1.0
			}, completion: nil)
		
		self.emailField.alpha = 0.0
		UIView.animateWithDuration(1.0, delay: 1.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.emailField.alpha = 1.0
			}, completion: nil)
		self.passwordField.alpha = 0.0
		UIView.animateWithDuration(1.0, delay: 1.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.passwordField.alpha = 1.0
			}, completion: nil)
		self.signInButton.alpha = 0.0
		UIView.animateWithDuration(1.0, delay: 1.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.signInButton.alpha = 1.0
			}, completion: nil)
		self.createAccountButton.alpha = 0.0
		UIView.animateWithDuration(1.0, delay: 1.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.createAccountButton.alpha = 1.0
			}, completion: nil)
		self.forgotButton.alpha = 0.0
		UIView.animateWithDuration(1.0, delay: 1.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.forgotButton.alpha = 1.0
			}, completion: nil)
    }
	
	@IBAction func forgotPasswordTapped(sender: AnyObject) {
		let alertViewController: UIAlertController = UIAlertController(title: "Enter Email", message: "Please enter your email so we can send you a reset link.", preferredStyle: .Alert)
		alertViewController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		alertViewController.addTextFieldWithConfigurationHandler { textField -> Void in
			
			self.emailTextField = textField
			self.emailTextField.autocapitalizationType = UITextAutocapitalizationType.Sentences
			self.emailTextField.placeholder = "Email is CaSe-sEnSiTiVe"
		}
		
		alertViewController.addAction(UIAlertAction(title: "Reset", style: .Default, handler: { _ in
			PFUser.requestPasswordResetForEmailInBackground(self.emailTextField.text!)
		}))
		
		self.presentViewController(alertViewController, animated: true, completion: nil)
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		emailField.resignFirstResponder()
		passwordField.resignFirstResponder()
		return true
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		emailField.resignFirstResponder()
		passwordField.resignFirstResponder()
	}
	
	func backFromModal(segue: UIStoryboardSegue) {
		print("and we are back")
		self.tabBarController?.selectedIndex = 1
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	@IBAction func signInTapped(sender: UIButton) {
		activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
		activityIndicator.center = self.view.center
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
		view.addSubview(activityIndicator)
		activityIndicator.startAnimating()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		
		if emailField.text == "" || passwordField.text == "" {
			let emptyView = UIAlertController(title: "Wrong Username or Password", message: "You entered either a wrong username or password.", preferredStyle: UIAlertControllerStyle.Alert)
			emptyView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		}
		
		PFUser.logInWithUsernameInBackground(emailField.text!, password: passwordField.text!) { (user: PFUser?, error: NSError?) -> Void in
			if(error == nil) {
				UIApplication.sharedApplication().endIgnoringInteractionEvents()
				let installation:PFInstallation = PFInstallation.currentInstallation()
				installation.addUniqueObject("Group1", forKey: "channels")
				installation["user"] = PFUser.currentUser()
				print(PFUser.currentUser())
				self.performSegueWithIdentifier("ShowTabs", sender: self)
			} else {
				Crashlytics.sharedInstance().recordError(error!)
				self.activityIndicator.stopAnimating()
				UIApplication.sharedApplication().endIgnoringInteractionEvents()
				print(error?.localizedDescription)
				if (PFErrorCode(rawValue: 101) != nil) {
					let emptyView = UIAlertController(title: "Wrong Username or Password", message: "You entered either a wrong username or password.", preferredStyle: UIAlertControllerStyle.Alert)
					emptyView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
					self.presentViewController(emptyView, animated: true, completion: nil)
				}
			}
		}
	}
}