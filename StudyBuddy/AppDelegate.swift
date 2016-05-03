//
//  AppDelegate.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/14/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse
import Fabric
import Crashlytics
import Bolts
import Foundation
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		Fabric.with([Crashlytics.self])
		Parse.setApplicationId("CTe0o6nbWeIB0xQnjJXAedLCgYAwlZDnUWpKmCUa", clientKey: "DaCKL4e8GQTD0ZfN6lb5arBHuEK554nHXQxAssJ4")
	
		let category = UIMutableUserNotificationCategory()
        category.identifier = "Message"
        let reply = UIMutableUserNotificationAction()
        reply.title = "Reply"
        
		if #available(iOS 9.0, *) {
			reply.identifier = "Reply"
			reply.activationMode = UIUserNotificationActivationMode.Background
			reply.destructive = false
			reply.authenticationRequired = false
			reply.behavior = UIUserNotificationActionBehavior.TextInput
		} else {
			reply.identifier = "OpenReply"
			reply.activationMode = UIUserNotificationActivationMode.Background
			reply.destructive = false
			reply.authenticationRequired = false
		}
        
        category.setActions([reply], forContext: UIUserNotificationActionContext.Default)
        category.setActions([reply], forContext: UIUserNotificationActionContext.Minimal)
		
		let noAction = UIMutableUserNotificationAction()
		noAction.identifier = "SIGN_OFF"
		noAction.title = "No"
		noAction.activationMode = .Background
		noAction.authenticationRequired = false
		noAction.destructive = true
		
		let availableCategory = UIMutableUserNotificationCategory()
		availableCategory.identifier = "Status"
		availableCategory.setActions([noAction], forContext: .Default)
		availableCategory.setActions([noAction], forContext: .Minimal)
        
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: Set(arrayLiteral: category, availableCategory))
        
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
		UIApplication.sharedApplication().registerForRemoteNotifications()
		
        UIStatusBarStyle.LightContent
		
		return true
	}
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        UIAlertView(title: notification.alertTitle, message: notification.alertBody, delegate: nil, cancelButtonTitle: "OK").show()
    }
	
    func applicationDidBecomeActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("reloadTimeline", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("checkStatus", object: nil)
		NSNotificationCenter.defaultCenter().postNotificationName("loadSubjects", object: nil)
		let currentInstallation = PFInstallation.currentInstallation()
		if PFUser.currentUser() != nil {
			currentInstallation.addUniqueObject("currentuser", forKey: "channels")
			currentInstallation["currentuser"] = PFUser.currentUser()?.email
			currentInstallation["user"] = PFUser.currentUser()
			currentInstallation.saveInBackground()
		}
		
		currentInstallation.saveInBackground()
    }
	
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		let installation = PFInstallation.currentInstallation()
		print(deviceToken)
		installation.setDeviceTokenFromData(deviceToken)
		installation.saveInBackground()
		
		if PFUser.currentUser() == nil {
			
		} else {
			let unreadQuery = PFQuery(className: "UnreadMessage")
			unreadQuery.whereKey("user", equalTo: PFUser.currentUser()!)
			unreadQuery.findObjectsInBackgroundWithBlock { (results:[PFObject]?, error: NSError?) in
				if error == nil {
					UIApplication.sharedApplication().applicationIconBadgeNumber = results!.count
				} else {
					print(error?.localizedDescription)
					Crashlytics.sharedInstance().recordError(error!)
				}
			}
		}
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
		print("received notification")
		
		let info: NSDictionary = userInfo as NSDictionary
		let notification:NSDictionary = info.objectForKey("aps") as! NSDictionary
		
		if (notification.objectForKey("content-available") != nil){
			if notification.objectForKey("content-available")!.isEqualToNumber(1){
				NSNotificationCenter.defaultCenter().postNotificationName("reloadTimeline", object: nil)
			}
		}
    }
	
	func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
		UIApplication.sharedApplication().applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber - UIApplication.sharedApplication().applicationIconBadgeNumber - UIApplication.sharedApplication().applicationIconBadgeNumber
        
        switch (identifier!) {
			case "SIGN_ON":
				PFUser.currentUser()!["available"] = true
				PFUser.currentUser()!["availableText"] = "True"
                PFUser.currentUser()?.saveInBackground()
			case "SIGN_OFF":
				PFUser.currentUser()!["available"] = false
				PFUser.currentUser()!["availableText"] = "False"
                PFUser.currentUser()?.saveInBackground()
			default:
				print("Error: unexpected notification action identifier!")
		}
		
		completionHandler() // per developer documentation, app will terminate if we fail to call this
	}
	
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print(userInfo)
        if #available(iOS 9.0, *) {
            if identifier == "REPLY_ACTION_SEND" {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadTimeline", object: nil)
                UIApplication.sharedApplication().applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber - UIApplication.sharedApplication().applicationIconBadgeNumber
                
                let aps = userInfo["aps"] as? NSDictionary
                let roomInfo = aps!["room"] as? NSDictionary
                let room = roomInfo!["objectId"] as? PFObject
                print(room)
                
                
                let userEmail = aps!["username"] as? String
                print(userEmail)
                
                let message = PFObject(className: "Messages")
                message["content"] = UIUserNotificationActionResponseTypedTextKey
                message["MessageRoom"] = room
                message["user"] = PFUser.currentUser()
                
                message.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error == nil {
                        room?["lastUpdate"] = NSDate()
                        room!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            if error == nil {
                            }
                        })
                        
                        let push = PFPush()
                        let pushQuery = PFInstallation.query()
                        
                        pushQuery!.whereKey("currentUser", equalTo: userEmail!)
                        
                        let data:NSDictionary = ["alert":"\(PFUser.currentUser()!["firstName"]): \(responseInfo[UIUserNotificationActionResponseTypedTextKey]!)", "Badge":"increment", "content-available":"1", "sound":"default", "category": "Message", "username": (PFUser.currentUser()?.username)!, "room": room!]
                        
                        push.setData(data as [NSObject : AnyObject]?)
                        push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if error == nil {
                                print("notification sent")
                            } else {
                                print(error)
                                Crashlytics.sharedInstance().recordError(error!)
                            }
                        })
                    } else {
                        print(error)
                        Crashlytics.sharedInstance().recordError(error!)
                    }
                })
            }
        } else {
            // Fallback on earlier versions
        }
        completionHandler()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if identifier == "REPLY_ACTION" {
            NSNotificationCenter.defaultCenter().postNotificationName("reply", object: nil)
        }
        completionHandler()
    }
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//		 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}