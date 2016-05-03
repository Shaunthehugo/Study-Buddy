//
//  AnnotationViewController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/28/16.
//  Copyright © 2016 foru. All rights reserved.
//

import Foundation
import UIKit
import Gecco
import Parse

class AnnotationViewController: SpotlightViewController {
	var stepIndex: Int = 0
	
	@IBOutlet var annotationViews: [UIView]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		delegate = self
		PFUser.currentUser()!["seenIntro"] = true
		PFUser.currentUser()?.saveInBackground()
	}
	
	func next(labelAnimated: Bool) {
		updateAnnotationView(labelAnimated)
		
		let screenSize = UIScreen.mainScreen().bounds.size
		
		switch stepIndex {
		case 0:
			spotlightView.appear(Spotlight.Oval(center: CGPointMake(screenSize.width - 350, 42), diameter: 55))
		case 1:
			spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width/2, screenSize.height-25), diameter: 55))
		case 2:
			spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width/2+125, screenSize.height-25), diameter: 55))
		case 3:
			spotlightView.move(Spotlight.RoundedRect(center: CGPointMake(screenSize.width/2, (screenSize.height/2)+8), size: CGSizeMake(screenSize.width, screenSize.height-115), cornerRadius: 6), moveType: .Disappear)
		case 4:
			dismissViewControllerAnimated(true, completion: nil)
		default:
			break
		}
		
		stepIndex += 1
	}
	
	func updateAnnotationView(animated: Bool) {
		annotationViews.enumerate().forEach { index, view in
			UIView .animateWithDuration(animated ? 0.25 : 0) {
				view.alpha = index == self.stepIndex ? 1 : 0
			}
		}
	}
}

extension AnnotationViewController: SpotlightViewControllerDelegate {
	func spotlightViewControllerWillPresent(viewController: SpotlightViewController, animated: Bool) {
		next(false)
	}
	
	func spotlightViewControllerTapped(viewController: SpotlightViewController, isInsideSpotlight: Bool) {
		next(true)
	}
	
	func spotlightViewControllerWillDismiss(viewController: SpotlightViewController, animated: Bool) {
		spotlightView.disappear()
	}
}
