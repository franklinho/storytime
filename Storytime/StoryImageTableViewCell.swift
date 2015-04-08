//
//  StoryImageTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class StoryImageTableViewCell: UITableViewCell {

    @IBOutlet weak var timestampView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    

    @IBOutlet weak var eventImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        timestampView.layer.cornerRadius = 5
        timestampView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
