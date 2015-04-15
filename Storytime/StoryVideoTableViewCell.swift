//
//  StoryVideoTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit
import AVFoundation

protocol StoryVideoTableViewCellDelegate{
    func playOrPauseVideoCell(videoCell : StoryVideoTableViewCell)
    func displayUserProfileView(user : PFUser)
}


class StoryVideoTableViewCell: UITableViewCell {
    var delegate : StoryVideoTableViewCellDelegate?
    
    var comment : PFObject?
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timestampView: UIView!
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
        
        timestampView.layer.cornerRadius = 5
        timestampView.clipsToBounds = true
        
        if profileImageView != nil {
            profileImageView.layer.cornerRadius = 31
            profileImageView.layer.borderWidth = 2
            profileImageView.layer.borderColor = UIColor.darkGrayColor().CGColor
            profileImageView.clipsToBounds = true
        }
        
        if userNameButton != nil {
            userNameButton.layer.cornerRadius = 10
            userNameButton.clipsToBounds = true
        }
        
            
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func videoViewWasTapped(sender: AnyObject) {
        self.delegate?.playOrPauseVideoCell(self)
    }
    
    @IBAction func showUserProfileWasTapped(sender: AnyObject) {
        self.delegate?.displayUserProfileView(self.comment!["user"] as PFUser)
    }
    

}
