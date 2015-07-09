//
//  FeedbackTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 7/9/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class FeedbackTableViewCell: UITableViewCell {

    @IBOutlet weak var feedbackTitle: UILabel!
    @IBOutlet weak var feedbackIconImage: UIImageView!
    var action : String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
