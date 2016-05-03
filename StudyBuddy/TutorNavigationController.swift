//
//  TutorNavigationController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/22/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit

class TutorNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
		UITabBar.appearance().tintColor = UIColor(red: 118.0/250.0, green: 196.0/250.0, blue: 230.0/250.0, alpha: 1)
		navigationBar.tintColor = UIColor.whiteColor()
		navigationBar.topItem?.titleView?.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
}
