//
//  RankingTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

// Protocol for triggering login/signup/createProfileViewControllers

protocol RankingTableViewCellDelegate{
    func displayLoginViewController()
    func displayCreateProfileViewController()
    func displayUserProfileView(user : PFUser)
    func displayCommentsViewFor(story : PFObject)
}

class RankingTableViewCell: UITableViewCell, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var delegate : RankingTableViewCellDelegate?

    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var voteView: UIView!
    var storyUpVoted = false
    var storyDownVoted = false
    var story : PFObject?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var thumbnailTextLabel: UILabel!
    var votedStories : NSMutableDictionary?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        voteView.layer.cornerRadius = 10
        voteView.clipsToBounds = true
        
        titleView.layer.cornerRadius = 10
        titleView.clipsToBounds = true
        
        commentsButton.layer.cornerRadius = 10
        commentsButton.clipsToBounds = true
        
        profileImageView.layer.cornerRadius = 31
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        profileImageView.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func upvoteButtonWasTapped(sender: AnyObject) {
        if (PFUser.currentUser() == nil){
            self.delegate?.displayLoginViewController()
            
        } else {
            upvoteStory()
        }
    }
    
    @IBAction func downvoteButtonWasTapped(sender: AnyObject) {
        if (PFUser.currentUser() == nil){
            self.delegate?.displayLoginViewController()
        } else {
            downvoteStory()
        }
    }
    
    func upvoteStory() {
        if PFUser.currentUser() != nil{
            if PFUser.currentUser()["votedStories"] != nil {
                if self.story != nil {
                    self.votedStories = PFUser.currentUser()["votedStories"] as NSMutableDictionary
                    if storyUpVoted == true {
                        self.votedStories![self.story!.objectId] = 0
                        storyUpVoted = false
                        upvoteButton.setImage(UIImage(named: "up_icon_white.png"), forState: UIControlState.Normal)
                        pointsLabel.textColor = UIColor.whiteColor()
                        self.story!["upvotes"] = self.story!["upvotes"] as Int - 1
                        var upvotes = story!["upvotes"] as Int
                        var downvotes = story!["downvotes"] as Int
                        self.story!["points"] = upvotes - downvotes
                    } else if storyDownVoted == true {
                        self.votedStories![self.story!.objectId] = 1
                        storyUpVoted = true
                        storyDownVoted = false
                        upvoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                        downvoteButton.setImage(UIImage(named: "down_icon_white.png"), forState: UIControlState.Normal)
                        pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                        self.story!["upvotes"] = self.story!["upvotes"] as Int + 1
                        self.story!["downvotes"] = self.story!["downvotes"] as Int - 1
                        var upvotes = story!["upvotes"] as Int
                        var downvotes = story!["downvotes"] as Int
                        self.story!["points"] = upvotes - downvotes
                    }else {
                        self.votedStories![self.story!.objectId] = 1
                        storyUpVoted = true
                        upvoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                        pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                        self.story!["upvotes"] = self.story!["upvotes"] as Int + 1
                        var upvotes = story!["upvotes"] as Int
                        var downvotes = story!["downvotes"] as Int
                        self.story!["points"] = upvotes - downvotes
                    }
                    
                    if self.story != nil {
                        self.story!.saveInBackground()
                        var points = self.story!["points"]
                        pointsLabel.text = "\(points)"
                    }
                    
                    PFUser.currentUser()["votedStories"] = self.votedStories
                    PFUser.currentUser().saveInBackground()
                }
            }
        }

    }
    
    func downvoteStory() {
        if PFUser.currentUser() != nil{
            if PFUser.currentUser()["votedStories"] != nil {
                if self.story != nil {
                    self.votedStories = PFUser.currentUser()["votedStories"] as NSMutableDictionary
                    if storyDownVoted == true {
                        self.votedStories![self.story!.objectId] = 0
                        storyDownVoted = false
                        downvoteButton.setImage(UIImage(named: "down_icon_white.png"), forState: UIControlState.Normal)
                        pointsLabel.textColor = UIColor.whiteColor()
                        self.story!["downvotes"] = self.story!["downvotes"] as Int - 1
                        var upvotes = story!["upvotes"] as Int
                        var downvotes = story!["downvotes"] as Int
                        self.story!["points"] = upvotes - downvotes
                    } else if storyUpVoted == true {
                        self.votedStories![self.story!.objectId] = -1
                        storyDownVoted = true
                        storyUpVoted = false
                        downvoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
                        upvoteButton.setImage(UIImage(named: "up_icon_white.png"), forState: UIControlState.Normal)
                        pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                        self.story!["downvotes"] = self.story!["downvotes"] as Int + 1
                        self.story!["upvotes"] = self.story!["upvotes"] as Int - 1
                        var upvotes = story!["upvotes"] as Int
                        var downvotes = story!["downvotes"] as Int
                        self.story!["points"] = upvotes - downvotes
                    }else {
                        self.votedStories![self.story!.objectId] = -1
                        storyDownVoted = true
                        downvoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
                        pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                        self.story!["downvotes"] = self.story!["downvotes"] as Int + 1
                        var upvotes = story!["upvotes"] as Int
                        var downvotes = story!["downvotes"] as Int
                        self.story!["points"] = upvotes - downvotes
                    }
                    
                    if self.story != nil {
                        self.story!.saveInBackground()
                        var points = self.story!["points"]
                        pointsLabel.text = "\(points)"
                    }
                    
                    PFUser.currentUser()["votedStories"] = self.votedStories
                    PFUser.currentUser().saveInBackground()
                }
            }
        }

    }
    
    @IBAction func userLabelWasTapped(sender: AnyObject) {
        self.delegate?.displayUserProfileView(self.story!["user"] as PFUser)
    }
    

    @IBAction func commentsButtonWasTapped(sender: AnyObject) {
        
        self.delegate?.displayCommentsViewFor(self.story!)

    }
}
