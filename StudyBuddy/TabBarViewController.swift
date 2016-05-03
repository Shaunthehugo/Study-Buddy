//
//  TabBarViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/21/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit
import Parse
import Foundation
import Crashlytics

class TabBarViewController: UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
}
