//
//  StoryVideoTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit
import AVFoundation

class StoryVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playButtonIconImageView: UIImageView!
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playButtonIconImageView.layer.cornerRadius = 100
        playButtonIconImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
