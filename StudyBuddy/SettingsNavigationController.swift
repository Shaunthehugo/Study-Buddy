//
//  NavigationViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/21/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit

class SettingsNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
}
