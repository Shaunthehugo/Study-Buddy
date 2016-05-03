//
//  PushNotificationController.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 4/2/16.
//  Copyright © 2016 foru. All rights reserved.
//

import Foundation
import Parse

class PushNotificationController : NSObject {
    
    override init() {
        super.init()
        
        Parse.setApplicationId("CTe0o6nbWeIB0xQnjJXAedLCgYAwlZDnUWpKmCUa", clientKey: "DaCKL4e8GQTD0ZfN6lb5arBHuEK554nHXQxAssJ4")
    }
}