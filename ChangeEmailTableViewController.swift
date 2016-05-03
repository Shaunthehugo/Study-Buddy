//
//  ChangeEmailTableViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 3/13/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse

class ChangeEmailTableViewController: UITableViewController {

    @IBOutlet var newEmailField: UITextField!
    @IBOutlet var verifyNewEmailField: UITextField!
    @IBOutlet var changeEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func changeEmailTapped(sender: AnyObject) {
        let email = newEmailField.text
        let vEmail = verifyNewEmailField.text
        
        if newEmailField.text?.isEmpty == true || verifyNewEmailField.text?.isEmpty == true {
            let alert = UIAlertView(title: "Text Fields Empty", message: "Please make sure both password fields are filled.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        
        if newEmailField.text == verifyNewEmailField.text {
            let alert = UIAlertView(title: "Emails Don't Match", message: "Please make sure your emails match.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else if email!.rangeOfString(".") == nil && email!.rangeOfString("@") == nil {
            let alert = UIAlertView(title: "Email Invalid", message: "Please enter a valid email.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else {
            PFUser.currentUser()?.email = vEmail
            PFUser.currentUser()?.saveInBackground()
            let alert = UIAlertView(title: "Success", message: "Your new email has been saved successfully", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            newEmailField.text = ""
            verifyNewEmailField.text = ""
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
