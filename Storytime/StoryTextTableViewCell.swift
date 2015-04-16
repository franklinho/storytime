
//
//  StoryTextTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

protocol StoryTextTableViewCellDelegate{
    func displayUserProfileView(user : PFUser)
}

class StoryTextTableViewCell: UITableViewCell {
    var deleteButtonExpanded = false    
    var comment : PFObject?
    var delegate : StoryVideoTableViewCellDelegate?
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var timestampView: UIView!
    @IBOutlet weak var eventTextLabel: UILabel!
    
    @IBOutlet weak var deleteDismissButton: UIButton!
    @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
        
        if deleteButton != nil {
            deleteButton.layer.cornerRadius = 22
            deleteButton.clipsToBounds = true
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showUserProfileWasTapped(sender: AnyObject) {
        self.delegate?.displayUserProfileView(self.comment!["user"] as PFUser)
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
        }
    }

    @IBAction func deleteDismissButtonWasTapped(sender: AnyObject) {
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
