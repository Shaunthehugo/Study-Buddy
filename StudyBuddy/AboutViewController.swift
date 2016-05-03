//
//  AboutViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/21/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

	@IBOutlet weak var iconsButton: UIButton!
	@IBOutlet weak var backButton: UIBarButtonItem!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	@IBAction func iconsTapped(sender: AnyObject) {
		let url = NSURL(string: "https://icons8.com")!
		UIApplication.sharedApplication().openURL(url)
	}
	
	@IBAction func backTapped(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: {})
	}
}
