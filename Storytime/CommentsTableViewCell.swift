//
//  CommentsTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 4/14/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var commentTitleView: UIView!

    @IBOutlet weak var commentVoteView: UIView!

    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var commentImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
