//
//  SubjectTableViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/24/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import MessageUI
import Parse
import Crashlytics

class SubjectTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

	@IBOutlet weak var suggestionButton: UIBarButtonItem!
	
	var subjects = ["English", "Math", "Sciences", "History"]
	var selectedSubject:String!
	
    override func viewDidLoad() {
        // Uncomment the following line to preserve selection between presentations
		PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig?, error: NSError?) -> Void in
			if error == nil {
                self.subjects = PFConfig.currentConfig().objectForKey("subjects") as! [String]
				self.tableView.reloadData()
			} else {
				Crashlytics.sharedInstance().recordError(error!)
			}
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig?, error: NSError?) -> Void in
			if error == nil {
				self.subjects = PFConfig.currentConfig().objectForKey("subjects") as! [String]
				self.tableView.reloadData()
			} else {
				Crashlytics.sharedInstance().recordError(error!)
			}
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.selectedSubject = subjects[indexPath.row]
		
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let subjectVC = sb.instantiateViewControllerWithIdentifier("subjectVC") as! SubjectViewController
		
		subjectVC.subjectName = selectedSubject!
		self.navigationController?.pushViewController(subjectVC, animated: true)
	}

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("subjectCell") as! SubjectTableViewCell
		cell.subjectLabel.text = subjects[indexPath.row]
		
		return cell
	}
	
	@IBAction func suggestionsTapped(sender: AnyObject) {
		let email = "Shaun.dougherty@me.com"
		
		if MFMailComposeViewController.canSendMail() {
			let messageController = MFMailComposeViewController()
            messageController.mailComposeDelegate = self
			messageController.setToRecipients(["\(email)"])
			messageController.setSubject("Subject Suggestion for Study Buddy")
			
			self.presentViewController(messageController, animated: true, completion: nil)
		} else {
			suggestionButton.enabled = false
			suggestionButton.tintColor = UIColor.grayColor()
		}
	}
	
	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}

}
