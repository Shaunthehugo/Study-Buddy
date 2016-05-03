//
//  ChangePasswordTableViewController.swift
//  
//
//  Created by Shaun Dougherty on 3/13/16.
//
//

import UIKit
import Parse

class ChangePasswordTableViewController: UITableViewController {

    @IBOutlet var newPasswordField: UITextField!
    @IBOutlet var verifyNewPasswordField: UITextField!
    @IBOutlet var changePasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func changePasswordTapped(sender: AnyObject) {
        let password = newPasswordField.text
        let vPassword = verifyNewPasswordField.text
        
        if newPasswordField.text?.isEmpty == true || verifyNewPasswordField.text?.isEmpty == true {
            let alert = UIAlertView(title: "Text Fields Empty", message: "Please make sure both password fields are filled.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        
        if newPasswordField.text == verifyNewPasswordField.text {
            let alert = UIAlertView(title: "Passwords Don't Match", message: "Please make sure your passwords match.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }else if password?.utf16.count < 5 || vPassword?.utf16.count < 5 {
            let alert = UIAlertView(title: "Password Too Short", message: "Please make sure your password is longer than 5 characters.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else {
            PFUser.currentUser()?.password = vPassword
            PFUser.currentUser()?.saveInBackground()
            let alert = UIAlertView(title: "Success", message: "Your new password has been saved successfully", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            newPasswordField.text = ""
            verifyNewPasswordField.text = ""
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
}
