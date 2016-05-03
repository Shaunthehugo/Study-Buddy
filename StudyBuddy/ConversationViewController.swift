//
//  ConversationViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/22/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse
import Crashlytics
import JSQMessagesViewController

class ConversationViewController: JSQMessagesViewController {

    //MARK: Variables
    var activityIndicator: UIActivityIndicatorView!
	var room: PFObject!
	var incomingUser: PFUser!
	var userList = [PFUser]()
	
	var messages = [JSQMessage]()
	var messageObjects = [PFObject]()
	var outgoingBubble : JSQMessagesBubbleImage!
    var incomingBubble: JSQMessagesBubbleImage!
	
    //MARK: View loaded
    override func viewDidLoad() {
        super.viewDidLoad()
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
		NSNotificationCenter.defaultCenter().postNotificationName("changeImageColor", object: nil)
		
        // Do any additional setup after loading the view.
		navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
		navigationItem.title = incomingUser?["firstName"] as? String

		self.inputToolbar!.contentView!.textView!.tintColor = UIColor(red: 118.0/250.0, green: 196.0/250.0, blue: 230.0/250.0, alpha: 1)
        self.inputToolbar!.contentView!.leftBarButtonItem = nil
		self.inputToolbar!.contentView!.rightBarButtonItem!.setTitleColor(UIColor(red: 118.0/250.0, green: 196.0/250.0, blue: 230.0/250.0, alpha: 1), forState: UIControlState.Normal)
		self.inputToolbar!.contentView!.rightBarButtonItem!.setTitleColor(UIColor(red: 107.0/250.0, green: 169.0/250.0, blue: 203.0/250.0, alpha: 1), forState: UIControlState.Highlighted)
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        self.senderId = PFUser.currentUser()?.objectId
		self.senderDisplayName = "\(PFUser.currentUser()!["firstName"])" + " \(PFUser.currentUser()!["lastName"])"
        
		let factory = JSQMessagesBubbleImageFactory()
		
        incomingBubble = factory.incomingMessagesBubbleImageWithColor(UIColor.groupTableViewBackgroundColor())
        outgoingBubble = factory.outgoingMessagesBubbleImageWithColor(UIColor(red: 118.0/250.0, green: 196.0/250.0, blue: 230.0/250.0, alpha: 1))
        
        self.automaticallyScrollsToMostRecentMessage = true
        self.scrollToBottomAnimated(false)
		
        loadMessages()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
        UIApplication.sharedApplication().applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber - UIApplication.sharedApplication().applicationIconBadgeNumber
        
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationViewController.loadMessages), name: "reloadTimeline", object: nil)
//		loadMessages()
	}
	
    //MARK: Get messages
	func loadMessages() {
		var lastMessage: JSQMessage?
		
		if messages.last != nil {
			lastMessage = messages.last
		}
		
		let messageQuery = PFQuery(className: "Messages")
        messageQuery.whereKey("MessageRoom", equalTo: room!)
		messageQuery.orderByAscending("createdAt")
		messageQuery.limit = 500
		messageQuery.includeKey("user")
		messageQuery.cachePolicy = .CacheThenNetwork
		
		if lastMessage != nil {
			messageQuery.whereKey("createdAt", greaterThan: lastMessage!.date)
		}
		
		let unreadQuery = PFQuery(className: "UnreadMessage")
		unreadQuery.whereKey("user", equalTo: PFUser.currentUser()!)
		unreadQuery.whereKey("room", equalTo: room)
		unreadQuery.cachePolicy = .CacheThenNetwork
		
		unreadQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) in
			if error == nil {
				if results?.count > 0 {
					let unreadMessages = results! as [PFObject]
					
					for msg in unreadMessages {
						msg.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) in
							if error == nil {
								UIApplication.sharedApplication().applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber - UIApplication.sharedApplication().applicationIconBadgeNumber
								print("Deleted")
							} else {
								print(error?.localizedDescription)
								Crashlytics.sharedInstance().recordError(error!)
							}
						})
					}
				}
			}
		})
		
		messageQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				let messages = results as [PFObject]!
				
				PFObject.pinAllInBackground(results!)
				
				for message in messages {
                    self.messageObjects.append(message)
					
                    let user = message["user"] as! PFUser
                    self.userList.append(user)
                    
                    let chatMessage = JSQMessage(senderId: user.objectId, senderDisplayName: "\(user["firstName"])" + " \(user["lastName"])", date: message.createdAt, text: message["content"] as! String)
                    self.messages.append(chatMessage)
                    
                    if results!.count  != 0 {
                        self.finishReceivingMessageAnimated(true)
                    }
				}
            }
		}
    }
	
    //MARK: Collection view
	override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
		let message = messages[indexPath.row]
		
		if message.senderId == PFUser.currentUser()?.objectId {
			return outgoingBubble
		}
		
		return incomingBubble
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        
        if indexPath.item == 0 {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        if indexPath.item-1 > 0 {
            let previousMessage = messages[indexPath.item-1]
            if message.date.timeIntervalSinceDate(previousMessage.date) > 600 {
                return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
            }
        }
		
		return nil
	}
	
    override func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
    
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
		
		let message = messages[indexPath.row]
        
        cell.textView!.selectable = false
		cell.textView!.editable = false
		cell.textView!.dataDetectorTypes = UIDataDetectorTypes.All
    

		if message.senderId == self.senderId {
			cell.textView?.textColor = UIColor.whiteColor()
		} else {
			cell.textView?.textColor = UIColor.blackColor()
		}
		cell.textView?.linkTextAttributes = [NSForegroundColorAttributeName: (cell.textView?.textColor)!]
		
		return cell
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        if indexPath.item-1 > 0 {
            let previousMessage = messages[indexPath.item-1]
            if message.date.timeIntervalSinceDate(previousMessage.date)/600 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        
        return 0
    }
    
	override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        if indexPath.item-1 > 0 {
            let previousMessage = messages[indexPath.item-1]
            if message.date.timeIntervalSinceDate(previousMessage.date)/600 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        
        return 0
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messageObjects.count
	}
    
    //MARK: Send Messages
	override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
		let message = PFObject(className: "Messages")
        message["content"] = text
		message["MessageRoom"] = room
        message["user"] = PFUser.currentUser()
        
		message.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
			if error == nil {
				self.loadMessages()
				
				self.room?["lastUpdate"] = NSDate()
				self.room.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
					if error == nil {
					}
				})
				
				let userEmail = self.incomingUser?.email
				
                let push: PFPush = PFPush()
				
				let pushQuery = PFInstallation.query()
				pushQuery!.whereKey("currentUser", equalTo: userEmail!)
				
                let data:NSDictionary = ["alert":"\(PFUser.currentUser()!["firstName"]): \(text)", "Badge":"increment", "content-available":"1", "sound":"default", "category": "Message", "username": (PFUser.currentUser()?.username)!, "room": self.room!]
                
                push.setData(data as [NSObject : AnyObject]?)
				push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) in
					if error == nil {
						print("notification sent")
					} else {
						print(error)
						Crashlytics.sharedInstance().recordError(error!)
					}
				})
				
				let unreadMessage = PFObject(className: "UnreadMessage")
				unreadMessage["user"] = self.incomingUser
				unreadMessage["room"] = self.room
				unreadMessage.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
					if success == true {
						
					} else {
						print(error?.localizedDescription)
						Crashlytics.sharedInstance().recordError(error!)
					}
				})
			} else {
				Crashlytics.sharedInstance().recordError(error!)
				print(error?.localizedDescription)
			}
		})
        
//        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessageAnimated(true)
    }
    
    //MARK: ETC
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
}