//
//  TutorViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/15/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse
import Crashlytics
import AFNetworking
import Timepiece
import DZNEmptyDataSet

class TutorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
	var messageList = [PFObject]()
	var userList = [PFUser]()
	var messagePartner: PFUser!
    var reachabilityManager: AFNetworkReachabilityManager!
	var annotationViewController: AnnotationViewController?
    
    @IBOutlet weak var reachabilityLabel: UILabel!
	@IBOutlet weak var messagesTable: UITableView!

    func notification() {
		let dateComp:NSDateComponents = NSDateComponents()
		dateComp.hour = 17;
		dateComp.minute = 00;
		dateComp.timeZone = NSTimeZone.systemTimeZone()
		
		let calender:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let date:NSDate = calender.dateFromComponents(dateComp)!
		
		let checkInStatus: UILocalNotification = UILocalNotification()
        checkInStatus.fireDate = date
		checkInStatus.repeatInterval = NSCalendarUnit.Weekday
		checkInStatus.soundName = UILocalNotificationDefaultSoundName
        checkInStatus.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
		checkInStatus.timeZone = NSCalendar.currentCalendar().timeZone
        checkInStatus.alertBody = "Are you available to tutor?"
		checkInStatus.category = "Status"
		
		UIApplication.sharedApplication().scheduleLocalNotification(checkInStatus)
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let leftButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TutorViewController.showEditing))

        self.navigationItem.leftBarButtonItem = leftButton
		
		if PFUser.currentUser()!["tutor"] as! Bool == true {
			notification()
		}
		
		print(PFUser.currentUser())
		
        reachabilityManager?.startMonitoring()
        
        self.messagesTable.emptyDataSetDelegate = self
        self.messagesTable.emptyDataSetSource = self
		self.messagesTable.delegate = self
		self.messagesTable.dataSource = self
		loadMessages()
    }
	
	func presentAnnotation() {
		tabBarController!.tabBar.alpha = 0.5
		let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Annotation") as? AnnotationViewController
		viewController!.alpha = 0.5
		presentViewController(viewController!, animated: true, completion: nil)
		annotationViewController = viewController
		
		PFUser.currentUser()!["seenIntro"] = true
		PFUser.currentUser()?.saveInBackground()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	override func viewDidAppear(animated: Bool) {
        loadMessages()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TutorViewController.loadMessages), name: "reloadTimeline", object: nil)
		let unreadQuery = PFQuery(className: "UnreadMessage")
		unreadQuery.whereKey("user", equalTo: PFUser.currentUser()!)
		unreadQuery.cachePolicy = .CacheThenNetwork
		
		unreadQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) in
			if error == nil {
				if results?.count > 0 {
					UIApplication.sharedApplication().applicationIconBadgeNumber = results!.count
				}
			}
		})
	}
	
    func emptyDataSetDidAppear(scrollView: UIScrollView!) {
        self.messagesTable.separatorColor = UIColor.clearColor()
    }
    
    func emptyDataSetDidDisappear(scrollView: UIScrollView!) {
        self.messagesTable.separatorColor = UIColor.lightGrayColor()
    }
	
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let labelFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
        let attributes :[String:AnyObject] = [NSFontAttributeName : labelFont!]
        let title: NSAttributedString = NSAttributedString(string: "No Recent Conversations", attributes: attributes)
    
        return title
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let labelFont = UIFont(name: "HelveticaNeue", size: 14)
        let attributes :[String:AnyObject] = [NSFontAttributeName : labelFont!]
        let title: NSAttributedString = NSAttributedString(string: "Go To The Tutor List For Help", attributes: attributes)
        
        return title
    }
    
	func loadMessages() {
		messageList = [PFObject]()
		userList = [PFUser]()

//		let pred = NSPredicate(format: "user1 = %@ OR user2 = %@", PFUser.currentUser()!,PFUser.currentUser()!)
		
		let roomQuery = PFQuery(className: "Room")//, predicate: pred)
		roomQuery.includeKey("user1")
		roomQuery.includeKey("user2")
		roomQuery.orderByDescending("lastUpdate")
		roomQuery.cachePolicy = .NetworkElseCache
		
		roomQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				PFObject.pinAllInBackground(results)
				
				self.messageList = results! as [PFObject]
				
				for message in self.messageList {
					let user1 = message["user1"] as! PFUser
					let user2 = message["user2"] as! PFUser
					
					if user1.objectId != PFUser.currentUser()?.objectId {
						self.userList.append(user1)
					}
					
					if user2.objectId != PFUser.currentUser()?.objectId {
						self.userList.append(user2)
					}
				}
				
				self.messagesTable.reloadData()
            }
		}
	}
	
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.messageList[indexPath.row].deleteInBackground()
            self.messageList.removeAtIndex(indexPath.row)
            self.messagesTable.reloadData()
        }
    }
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
		messagePartner = userList[indexPath.row]
		
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let conversationVC = sb.instantiateViewControllerWithIdentifier("conversationVC") as! ConversationViewController
		
		let user1 = PFUser.currentUser()
		let user2 = userList[indexPath.row]
		
		let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2 as CVarArgType, user2 as CVarArgType, user1!)
		
		let roomQuery = PFQuery(className: "Room", predicate: pred)
		roomQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				let room = results!.last
				conversationVC.room = room
				conversationVC.incomingUser = user2
				self.navigationController?.pushViewController(conversationVC, animated: true)
			}
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messageList.count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = messagesTable.dequeueReusableCellWithIdentifier("messageCell") as! MessageTableViewCell
		
		cell.markRead.hidden = true
		
        let user1 = PFUser.currentUser()
        let user2 = userList[indexPath.row]
		
        let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2, user2, user1!)
        
        let roomQuery = PFQuery(className: "Room", predicate: pred)
		roomQuery.cachePolicy = .CacheThenNetwork
        
        roomQuery.findObjectsInBackgroundWithBlock { (results:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                if results!.count > 0 {
                    let messageQuery = PFQuery(className: "Messages")
					messageQuery.cachePolicy = .CacheThenNetwork
                    let room = results?.last
					
					let unreadQuery = PFQuery(className: "UnreadMessage")
					unreadQuery.whereKey("user", equalTo: PFUser.currentUser()!)
					unreadQuery.whereKey("room", equalTo: room!)
					unreadQuery.cachePolicy = .CacheThenNetwork
					
					unreadQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) in
						if error == nil {
							if results?.count > 0 {
								cell.markRead.hidden = false
							}
						}
					})
                    
                    messageQuery.whereKey("MessageRoom", equalTo: room!)
                    messageQuery.limit = 1
                    messageQuery.orderByDescending("createdAt")
                    messageQuery.findObjectsInBackgroundWithBlock({ (results:[PFObject]?, error:NSError?) -> Void in
                        if error == nil {
                            if results!.count > 0 {
                                let message = results?.last
								
								
								cell.messageLabel.text = message!["content"] as? String
                                
                                let date = message!.createdAt
                                let interval = date?.timeIntervalSinceReferenceDate
                                
                                var dateString = ""
                                
                                if interval == 0 {
                                    dateString = "Today"
                                } else if interval == 1{
                                    dateString = "Yesterday"
                                } else if interval > 1 {
									
                                    let dateFormat = NSDateFormatter()
                                    dateFormat.dateFormat = "h:mm a"
									dateFormat.timeZone = NSTimeZone.localTimeZone()
									
                                    dateString = dateFormat.stringFromDate(message!.createdAt!)
                                }
                                
                                cell.dateLabel.text = dateString as String
                            }else{
                                cell.messageLabel.text = "No messages yet"
                            }
                        }
                    })
                }
            }
        }
        
        let messageObject = messageList[indexPath.row]
		let targetUser = userList[indexPath.row]
		
        let messageText = messageObject["lastUpdate"] as? String
        let subjectName = targetUser["subject"]
		let firstName = targetUser["firstName"]
		let lastName = targetUser["lastName"]
        
		
        cell.textLabel!.text = messageText
		cell.nameLabel.text = "\(firstName!)" + " \(lastName!)"
        if subjectName == nil {
            cell.subjectLabel.text = "Student"
        } else {
            cell.subjectLabel.text = subjectName as? String
        }
        
		return cell
	}
    
    func showEditing()
    {
        if(self.messagesTable.editing == true)
        {
            self.messagesTable.editing = false
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        }
        else
        {
            self.messagesTable.editing = true
            self.navigationItem.leftBarButtonItem?.title = "Cancel"
        }
    }
}
