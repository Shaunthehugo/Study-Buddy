//
//  SubjectViewController.swift
//  Pods
//
//  Created by Shaun Dougherty on 3/20/16.
//
//

import UIKit
import Parse
import Crashlytics
import DZNEmptyDataSet

class SubjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	var tutorList: [PFObject]! = []
	var username:String!
	var usernames: [String]! = []
	var userList: NSMutableArray = NSMutableArray()
	var selectedUser: PFUser!
	var subjectName:String!
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = subjectName
		
		self.tableView.emptyDataSetSource = self
		self.tableView.emptyDataSetDelegate = self
		self.tableView.dataSource = self
		self.tableView.delegate = self
		
		// Do any additional setup after loading the view
		loadUsers(subjectName)
	}
	
	func emptyDataSetDidAppear(scrollView: UIScrollView!) {
		self.tableView.separatorColor = UIColor.clearColor()
	}
	
	func emptyDataSetDidDisappear(scrollView: UIScrollView!) {
		self.tableView.separatorColor = UIColor.lightGrayColor()
	}
	
	func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
		let labelFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
		let attributes :[String:AnyObject] = [NSFontAttributeName : labelFont!]
		let title: NSAttributedString = NSAttributedString(string: "No Tutors Are Available", attributes: attributes)
		
		return title
	}
	
	func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
		let labelFont = UIFont(name: "HelveticaNeue", size: 15)
		let buttonTint = UIColor(red: 118.0/250.0, green: 196.0/250.0, blue: 230.0/250.0, alpha: 1)
		let attributes :[String:AnyObject] = [NSFontAttributeName : labelFont!, NSForegroundColorAttributeName: buttonTint]
		let title: NSAttributedString = NSAttributedString(string: "Invite Users", attributes: attributes)
		
		return title
	}
	
	override func viewDidAppear(animated: Bool) {
		print(subjectName)
		loadUsers(subjectName)
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	func loadUsers(subject: String) {
		let findTutors = PFUser.query()
		
		findTutors?.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
		findTutors!.whereKey("tutor", equalTo: true)
		findTutors!.whereKey("subject", equalTo: subject)
		findTutors?.whereKey("available", equalTo: true)
		findTutors!.orderByAscending("available")
		findTutors!.orderByAscending("lastName")
		
		findTutors?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
			PFObject.pinAllInBackground(objects!)
			if error == nil {
				self.tutorList.removeAll()
				self.userList = NSMutableArray(array: objects! as! [PFUser])
				self.tableView.reloadData()
			} else {
				Crashlytics.sharedInstance().recordError(error!)
				findTutors?.fromPin()
				findTutors?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
					if error == nil {
						self.userList = NSMutableArray(array: objects! as! [PFUser])
						self.tableView.reloadData()
					} else {
						Crashlytics.sharedInstance().recordError(error!)
					}
				})
			}
		})
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return userList.count
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		selectedUser = userList.objectAtIndex(indexPath.row) as! PFUser
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let conversationVC = sb.instantiateViewControllerWithIdentifier("conversationVC") as! ConversationViewController
		
		var room = PFObject(className: "Room")
		
		let user1 = PFUser.currentUser()
		let user2 = userList[indexPath.row]
		
		let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2 as! CVarArgType, user2 as! CVarArgType, user1!)
		
		let roomQuery = PFQuery(className: "Room", predicate: pred)
		roomQuery.cachePolicy = .CacheThenNetwork
		
		roomQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) in
			if error == nil {
				if results!.count > 0 { // room already existing
					
					room = results!.last! as PFObject
					// Setup MessageViewController and Push to the MessageVC
//					conversationVC.room = room
//					conversationVC.incomingUser = user2 as! PFUser
//					self.navigationController?.pushViewController(conversationVC, animated: true)
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
					
				} else { // create a new room
					room["user1"] = user1
					room["user2"] = user2
					
					room.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
						if error == nil {
							conversationVC.room = room
							conversationVC.incomingUser = user2 as! PFUser
							self.navigationController?.pushViewController(conversationVC, animated: true)
						} else {
							Crashlytics.sharedInstance().recordError(error!)
						}
					})
				}
			}
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("englishCell", forIndexPath: indexPath) as! TutorTableViewCell
		
		let user:PFUser = userList.objectAtIndex(indexPath.row) as! PFUser
//		user.pinInBackground()
		
		user.saveEventually()
		
		let firstName = user["firstName"] as! String
		let lastName = user["lastName"] as! String
		let name = ("\(firstName)" + " \(lastName)")
		
		cell.nameLabel?.text = name
		cell.subjectLabel?.text = subjectName
		
		return cell
	}
}