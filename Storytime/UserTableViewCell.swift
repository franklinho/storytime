//
//  UserTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 4/20/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if userImageView != nil {
            userImageView.layer.cornerRadius = 30
            userImageView.layer.borderWidth = 2
            userImageView.layer.borderColor = UIColor.darkGrayColor().CGColor
            userImageView.clipsToBounds = true
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.userImageView.image = nil
        self.usernameLabel.text = ""
    }
    
    func populateCellWithUser(user:PFObject) {
        if user["profileImage"] != nil {
            let userImageFile = user["profileImage"] as PFFile
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    let image = UIImage(data:imageData)
                    self.userImageView.image = image
                }
            }
        }
        self.usernameLabel.text = user["profileName"] as? String
    }

}
