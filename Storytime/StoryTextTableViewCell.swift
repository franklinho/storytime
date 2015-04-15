
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
    var comment : PFObject?
    var delegate : StoryVideoTableViewCellDelegate?
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var timestampView: UIView!
    @IBOutlet weak var eventTextLabel: UILabel!
    
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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showUserProfileWasTapped(sender: AnyObject) {
        self.delegate?.displayUserProfileView(self.comment!["user"] as PFUser)
    }
    


}
