//
//  SettingsTableViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/21/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse
import Crashlytics

class SettingsTableViewController: UITableViewController {

	@IBOutlet weak var tutorCell: UITableViewCell!
	@IBOutlet weak var availablitySwitch: UISwitch!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if availablitySwitch.on {
			PFUser.currentUser()!["available"] = true
			PFUser.currentUser()!["availableText"] = "true"
		} else {
			PFUser.currentUser()!["available"] = false
			PFUser.currentUser()!["availableText"] = "false"
		}
		
		PFUser.currentUser()?.saveInBackground()
		tableView.beginUpdates()
		tableView.endUpdates()
    }
	
	override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationViewController.loadMessages), name: "checkStatus", object: nil)
		getStatus()
        if availablitySwitch.on {
            PFUser.currentUser()!["available"] = true
            PFUser.currentUser()!["availableText"] = "true"
        } else {
            PFUser.currentUser()!["available"] = false
            PFUser.currentUser()!["availableText"] = "false"
        }
        
        PFUser.currentUser()?.saveInBackground()
        tableView.beginUpdates()
        tableView.endUpdates()
	}
    
    func getStatus() {
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) in
            let status: Bool = PFUser.currentUser()!["available"] as! Bool
            
            if status == true {
                self.availablitySwitch.setOn(true, animated: true)
            } else {
                self.availablitySwitch.setOn(false, animated: true)
            }
        })
    }
	
	@IBAction func switchValueChanged(sender: UISwitch) {
		tableView.beginUpdates()
		tableView.endUpdates()
		
		if availablitySwitch.on {
			PFUser.currentUser()!["available"] = true
			PFUser.currentUser()!["availableText"] = "true"
		} else {
			PFUser.currentUser()!["available"] = false
			PFUser.currentUser()!["availableText"] = "false"
		}
		
		PFUser.currentUser()?.saveInBackground()
	}
	
	@IBAction func logOutTapped(sender: AnyObject) {
		PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
			if error == nil {
				self.performSegueWithIdentifier("LogOut", sender: self)
			} else {
				Crashlytics.sharedInstance().recordError(error!)
				print(error?.localizedDescription)
			}
		}
		print(PFUser.currentUser())
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row == 3 {
			performSegueWithIdentifier("changeEmail", sender: self)
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.row == 0 && PFUser.currentUser()!["tutor"] as! Bool == false {
			return 0
		}
		
		return 44
	}
}
