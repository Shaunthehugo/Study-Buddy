//
//  MessageTableViewCell.swift
//  StudyBuddy
//
//  Created by Shaun Dougherty on 2/24/16.
//  Copyright © 2016 foru. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var subjectLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var markRead: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
