//
//  StoryImageTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

protocol StoryImageTableViewCellDelegate{
    func displayUserProfileView(user : PFUser)
    func deleteCell(cell : UITableViewCell)
    func optionsWasTapped(cell: UITableViewCell, event: PFObject, type: String)
}

class StoryImageTableViewCell: UITableViewCell {
    var deleteButtonExpanded = false
    var comment : PFObject?
    var event : PFObject?
    var delegate : StoryImageTableViewCellDelegate?
    @IBOutlet weak var timestampView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var deleteButton: UIButton!

    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var deleteDismissButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
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
    
    @IBAction func showUserProfileWasTapped(sender: AnyObject) {
        if self.comment != nil {
            self.delegate?.displayUserProfileView(self.comment!["user"] as! PFUser)
        } else {
            self.delegate?.displayUserProfileView(self.event!["user"] as! PFUser)
        }
    }
    @IBAction func deleteButtonWasTapped(sender: AnyObject) {
        if self.event != nil {
            self.delegate?.optionsWasTapped(self, event: self.event!, type: "photo")
        } else if self.comment != nil {
            self.delegate?.optionsWasTapped(self, event: self.comment!, type: "photo")
        }
//        if deleteButtonExpanded == false {
//            self.contentView.layoutIfNeeded()
//            self.deleteButtonWidthConstraint.constant = 132
//            UIView.animateWithDuration(0.3, animations: {
//                self.contentView.layoutIfNeeded()
//                }, completion: {
//                    (value: Bool) in
//                    self.deleteButton.backgroundColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.75)
//                    self.deleteButtonExpanded = true
//                    self.deleteButton.setTitle("Delete", forState: UIControlState.Normal)
//                    self.deleteDismissButton.enabled = true
//            })
//        } else {
//            self.delegate?.deleteCell(self)
//        }
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
//        self.deleteButton.hidden = true
        self.minimizeDeleteButton()
        if self.profileImageView != nil {
            self.profileImageView.image = UIImage(named: "user_icon_scaled_white.png")
        }
        self.eventImageView.image = nil
        
    }
    
    func populateCellWithEvent(event: PFObject) {
        if event.createdAt == nil {
            self.timestampLabel.text = "0s ago"
        } else {
            self.timestampLabel.text = timeSinceTimeStamp(event.createdAt!)
        }
        let userImageFile = event["image"] as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData, error) -> Void in
            if error == nil {
                let image = UIImage(data:imageData!)
                self.eventImageView.hidden = true
                self.eventImageView.image = image
                self.eventImageView.alpha = 0
                self.eventImageView.hidden = false
                UIView.animateWithDuration(0.3, animations: {
                    self.eventImageView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                        
                })
            }
        }
        
        if event["user"] != nil {
            var eventUser = event["user"] as! PFUser
            eventUser.fetchIfNeededInBackgroundWithBlock {
                (post, error) -> Void in
                if eventUser["profileName"] != nil {
                    var profileName : String = eventUser["profileName"] as! String
                    self.userNameButton.setTitle("  \(profileName)  ", forState: UIControlState.Normal)
                    self.userNameButton.hidden = false
                }
                if eventUser["profileImage"] != nil {
                    var profileImageFile = eventUser["profileImage"] as! PFFile
                    profileImageFile.getDataInBackgroundWithBlock {
                        (imageData, error) -> Void in
                        if error == nil {
                            let image = UIImage(data:imageData!)
                            self.profileImageView.image = image
                            self.profileImageView.alpha = 0
                            self.profileImageView.hidden = false
                            UIView.animateWithDuration(0.3, animations: {
                                self.profileImageView.alpha = 1
                                }, completion: {
                                    (value: Bool) in
                                    
                            })
                        }
                    }
                }
                if PFUser.currentUser() != nil {
                    var currentUser = PFUser.currentUser()!
                    currentUser.fetchIfNeededInBackgroundWithBlock {
                        (post, error) -> Void in
                        println("Event user is \(eventUser.username) and current user is \(currentUser.username)")
//                        if  eventUser.username == currentUser.username {
//                            self.deleteButton!.hidden = false
//                        } else {
//                            self.deleteButton!.hidden = true
//                        }
                    }
                } else {
                    self.deleteButton!.hidden = true
                }
                
            }
        } else {
            self.deleteButton!.hidden = true
        }
    }
    
    func populateCellWithComment(comment: PFObject) {
        if comment.createdAt == nil {
            self.timestampLabel.text = "0s ago"
        } else {
            self.timestampLabel.text = timeSinceTimeStamp(comment.createdAt!)
        }
        let userImageFile = comment["image"] as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData, error) -> Void in
            if error == nil {
                let image = UIImage(data:imageData!)
                self.eventImageView.hidden = true
                self.eventImageView.image = image
                self.eventImageView.alpha = 0
                self.eventImageView.hidden = false
                UIView.animateWithDuration(0.3, animations: {
                    self.eventImageView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                        
                })
            }
        }
        var commentUser : PFUser = comment["user"] as! PFUser
        commentUser.fetchIfNeededInBackgroundWithBlock {
            (post, error) -> Void in
            if commentUser["profileName"] != nil {
                var profileName : String = commentUser["profileName"] as! String
                self.userNameButton.setTitle("  \(profileName)  ", forState: UIControlState.Normal)
                self.userNameButton.hidden = false
            }
            if commentUser["profileImage"] != nil {
                var profileImageFile = commentUser["profileImage"] as! PFFile
                profileImageFile.getDataInBackgroundWithBlock {
                    (imageData, error) -> Void in
                    if error == nil {
                        let image = UIImage(data:imageData!)
                        self.profileImageView.image = image
                        self.profileImageView.alpha = 0
                        self.profileImageView.hidden = false
                        UIView.animateWithDuration(0.3, animations: {
                            self.profileImageView.alpha = 1
                            }, completion: {
                                (value: Bool) in
                                
                        })
                    }
                }
            }
            
            if PFUser.currentUser() != nil {
                var currentUser = PFUser.currentUser()!
                println("Comment user is \(commentUser.username) and current user is \(currentUser.username)")
                if  commentUser.username == currentUser.username {
                    self.deleteButton!.hidden = false
                } else {
                    self.deleteButton!.hidden = true
                }
            } else {
                self.deleteButton!.hidden = true
            }
        }

    }
    
    func timeSinceTimeStamp(timeStamp : NSDate) -> String {
        // Calculate time since tweet creation
        var secondsBetween : NSTimeInterval = NSDate().timeIntervalSinceDate(timeStamp)
        var numberOfMinutesDouble = secondsBetween/60 as Double
        var numberOfMinutes : Int = Int(numberOfMinutesDouble)
        
        //        println("\(numberOfMinutes)")
        
        var timeSinceEvent : String?
        
        if numberOfMinutes < 60 {
            timeSinceEvent = "\(numberOfMinutes)m ago"
        } else if numberOfMinutes < 1440 && numberOfMinutes >= 60 {
            var hours = Int(numberOfMinutes/60)
            timeSinceEvent = "\(hours)h ago"
        } else {
            let oldDateFormatter = NSDateFormatter()
            oldDateFormatter.dateFormat = "MM/dd/yy"
            timeSinceEvent = oldDateFormatter.stringFromDate(timeStamp)
        }
        
        return timeSinceEvent!
        
    }
}
