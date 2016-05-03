//
//  ViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/14/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    let sawIntro: Bool = false
    
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func viewDidAppear(animated: Bool) {
		let user = PFUser.currentUser()
		if user?.objectId == nil {
//            if sawIntro == false {
//                self.performSegueWithIdentifier("goToIntro", sender: self)
//            } else {
                self.performSegueWithIdentifier("ShowLogin", sender: self)
//            }
		} else {
			self.performSegueWithIdentifier("UserLoggedIn", sender: self)
		}
		
//		if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == true {
//			print("Registered")
//		}
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
}