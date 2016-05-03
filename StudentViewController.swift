//
//  StudentViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/15/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse

class StudentViewController: UIViewController, UITableViewDelegate {

	var tutorList: NSMutableArray = NSMutableArray()
	var username:String!
	var usernames: [String]! = []
	@IBOutlet weak var englishView: UIView!
	@IBOutlet weak var mathView: UIView!
	@IBOutlet weak var scienceView: UIView!
	@IBOutlet weak var historyView: UIView!
	
	@IBOutlet weak var subjectControl: UISegmentedControl!
	@IBOutlet weak var subjectBar: UINavigationBar!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print(PFUser.currentUser())
		
		englishView.hidden = false
		mathView.hidden = true
		scienceView.hidden = true
		historyView.hidden = true
		
		
		print("Got here")
    }
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	
	@IBAction func subjectChanged(sender: UISegmentedControl) {
		switch subjectControl.selectedSegmentIndex {
		case 0:
			print("English selected")
			englishView.hidden = false
			mathView.hidden = true
			scienceView.hidden = true
			historyView.hidden = true
			
		case 1:
			print("Math selected")
			englishView.hidden = true
			mathView.hidden = false
			scienceView.hidden = true
			historyView.hidden = true
			
		case 2:
			print("Science selected")
			englishView.hidden = true
			mathView.hidden = true
			scienceView.hidden = false
			historyView.hidden = true
			
		case 3:
			print("History selected")
			englishView.hidden = true
			mathView.hidden = true
			scienceView.hidden = true
			historyView.hidden = false
			
		default:
			break
		}
	}
	
	func loadUsers(subject: String, tableView: UITableView) {
		let findTutors: PFQuery = PFUser.query()!
		
		findTutors.whereKey("subject", equalTo: subject)
		
		findTutors.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				self.tutorList = NSMutableArray(array: objects!)
				tableView.reloadData()
			}
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("tutorTableViewCell", forIndexPath: indexPath)
		
		let user: PFUser = tutorList.objectAtIndex(indexPath.row) as! PFUser
		
		cell.tag = indexPath.row
		
		username = user.username
		let firstName = user["firstName"]
		let lastName = user["lastName"]
		let name = ("\(firstName)" + " \(lastName)")
		
		return cell
	}
	
}