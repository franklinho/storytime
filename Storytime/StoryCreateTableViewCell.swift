//
//  StoryCreateTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class StoryCreateTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UIView!

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var videoView: UIView!
    var creationViews = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
        creationViews = [textView,cameraView,videoView]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
