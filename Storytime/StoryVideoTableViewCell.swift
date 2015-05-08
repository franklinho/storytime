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
    func deleteCell(cell : UITableViewCell)
}


class StoryVideoTableViewCell: UITableViewCell {
    var delegate : StoryVideoTableViewCellDelegate?
    var deleteButtonExpanded = false
    
    @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    var comment : PFObject?
    var event: PFObject?
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timestampView: UIView!
    @IBOutlet weak var playButtonIconImageView: UIImageView!
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var deleteDismissButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
        playButtonIconImageView.layer.cornerRadius = 100
        playButtonIconImageView.clipsToBounds = true
        
        timestampView.layer.cornerRadius = 5
        timestampView.clipsToBounds = true
        
        if profileImageView != nil {
            profileImageView.layer.cornerRadius = 31
            profileImageView.layer.borderWidth = 2
            profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
            profileImageView.clipsToBounds = true
        }
        
        if userNameButton != nil {
            userNameButton.layer.cornerRadius = 10
            userNameButton.clipsToBounds = true
        }
        
        if deleteButton != nil {
            deleteButton.layer.cornerRadius = 22
            deleteButton.clipsToBounds = true
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
        if self.comment != nil {
            self.delegate?.displayUserProfileView(self.comment!["user"] as! PFUser)
        } else {
            self.delegate?.displayUserProfileView(self.event!["user"] as! PFUser)
        }
    }
    

    @IBAction func deleteButtonWasTapped(sender: AnyObject) {
        if deleteButtonExpanded == false {
            self.contentView.layoutIfNeeded()
            self.deleteButtonWidthConstraint.constant = 132
            UIView.animateWithDuration(0.3, animations: {
                self.contentView.layoutIfNeeded()
                }, completion: {
                    (value: Bool) in
                    self.deleteButton.backgroundColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.75)
                    self.deleteButtonExpanded = true
                    self.deleteButton.setTitle("Delete", forState: UIControlState.Normal)
                    self.deleteDismissButton.enabled = true
            })
        } else {
            self.delegate?.deleteCell(self)
        }
    }
    
    @IBAction func deleteDismissButtonWasTapped(sender: AnyObject) {
        minimizeDeleteButton()
    }
    
    func minimizeDeleteButton() {
        if deleteButtonExpanded == true {
            self.deleteButton.setTitle("X", forState: UIControlState.Normal)
            self.contentView.layoutIfNeeded()
            self.deleteButtonWidthConstraint.constant = 44
            UIView.animateWithDuration(0.3, animations: {
                self.contentView.layoutIfNeeded()
                }, completion: {
                    (value: Bool) in
                    self.deleteButton.backgroundColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 0.75)
                    self.deleteButtonExpanded = false
                    self.deleteDismissButton.enabled = false
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.timestampLabel.text = "0s ago"
        if self.userNameButton != nil {
            self.userNameButton.setTitle("", forState: UIControlState.Normal)
        }
        self.deleteButton.hidden = true
        self.minimizeDeleteButton()
        if self.profileImageView != nil {
            self.profileImageView.image = UIImage(named: "user_icon_scaled_white.png")
        }
        if self.playerLayer != nil {
            self.playerLayer!.removeFromSuperlayer()
        }
        
    }
    
    
    

}
