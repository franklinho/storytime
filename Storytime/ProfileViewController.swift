//
//  ProfileViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/8/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RankingTableViewCellDelegate,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var stories : NSArray?
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var votedStories : NSMutableDictionary = [:]
    var user : PFUser?
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var storyTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    var refreshControl : UIRefreshControl!
    var profileTabBarItem : UITabBarItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTabBarItem = self.tabBarController?.tabBar.items?[1] as UITabBarItem

        
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        profileImageView.layer.borderWidth = 4
        profileImageView.clipsToBounds = true
        
        if user == nil {
            if PFUser.currentUser() != nil {
                user = PFUser.currentUser()
            } else {
                presentLoginViewController()
            }
        }
        
        if user != nil {
            usernameLabel.text = user!["profileName"] as String
            var profileImageFile = user!["profileImage"] as PFFile
            profileImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    let image = UIImage(data:imageData)
                    self.profileImageView.image = image
                }
            }

        }

        // Do any additional setup after loading the view.
        storyTableView.delegate = self
        storyTableView.dataSource = self
        
        storyTableView.rowHeight = self.screenSize.width
        requestStories()
        GSProgressHUD.show()
        
        // Add pull to refresh to the tableview
        self.refreshControl = UIRefreshControl()
        var pullToRefreshString = "Pull to refresh"
        var pullToRefreshAttributedString : NSMutableAttributedString = NSMutableAttributedString(string: pullToRefreshString)
        pullToRefreshAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, countElements(pullToRefreshString)))
        self.refreshControl.attributedTitle = pullToRefreshAttributedString
        self.refreshControl.addTarget(self, action: "requestStories", forControlEvents: UIControlEvents.ValueChanged)
        self.storyTableView.addSubview(refreshControl)

        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = storyTableView.dequeueReusableCellWithIdentifier("RankingTableViewCell") as RankingTableViewCell
        cell.upvoteButton.setImage(UIImage(named: "up_icon_white.png"), forState: UIControlState.Normal)
        cell.downvoteButton.setImage(UIImage(named: "down_icon_white.png"), forState: UIControlState.Normal)
        cell.pointsLabel.textColor = UIColor.whiteColor()
        cell.delegate = self
        
        var story : PFObject?
        if stories != nil {
            story = stories![indexPath.row] as? PFObject
            cell.story = story
            cell.titleLabel.text = story!["title"] as? String
            var storyUser : PFUser = story!["user"] as PFUser
            storyUser.fetchIfNeeded()
            if storyUser["profileName"] != nil {
                var profileName : String = storyUser["profileName"] as String
                cell.userButton.setTitle(profileName, forState: UIControlState.Normal)
            }
            
            if storyUser["profileImage"] != nil {
                var profileImageFile = storyUser["profileImage"] as PFFile
                profileImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData!, error: NSError!) -> Void in
                    if error == nil {
                        let image = UIImage(data:imageData)
                        cell.profileImageView.image = image
                    }
                }
            }
            
            
            
            var upvotes = story!["upvotes"] as? Int
            var downvotes = story!["downvotes"] as? Int
            cell.pointsLabel.text = "\(upvotes!-downvotes!)"
            
            
            
            if PFUser.currentUser() != nil{
                if PFUser.currentUser()["votedStories"] != nil {
                    self.votedStories = PFUser.currentUser()["votedStories"] as NSMutableDictionary
                    if votedStories[story!.objectId] != nil{
                        if votedStories[story!.objectId] as Int == 1 {
                            cell.storyUpVoted = true
                            cell.upvoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                            cell.pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                        } else if votedStories[story!.objectId] as Int == -1 {
                            cell.storyDownVoted = true
                            cell.downvoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
                            cell.pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                        }
                    }
                }
            }
            
            
            
            cell.previewImageView.hidden = true
            if story!["thumbnailImage"] != nil {
                let imageFile = story!["thumbnailImage"] as PFFile
                imageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData!, error: NSError!) -> Void in
                    if error == nil {
                        let image = UIImage(data:imageData)
                        cell.previewImageView.image = image
                        cell.previewImageView.hidden = false
                        cell.thumbnailTextLabel.hidden = true
                    }
                }
            } else if story!["thumbnailVideoScreenCap"] != nil {
                let imageFile = story!["thumbnailVideoScreenCap"] as PFFile
                imageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData!, error: NSError!) -> Void in
                    if error == nil {
                        let image = UIImage(data:imageData)
                        cell.previewImageView.image = image
                        cell.previewImageView.hidden = false
                        cell.thumbnailTextLabel.hidden = true
                    }
                }
            } else if story!["thumbnailText"] != nil {
                cell.previewImageView.hidden = true
                cell.thumbnailTextLabel.hidden = false
                cell.thumbnailTextLabel.text = story!["thumbnailText"] as String
            }
        }
        cell.rankLabel.text = "\(indexPath.row+1)."
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stories != nil {
            return self.stories!.count
        } else {
            return 0
        }
    }
    
    func requestStories() {
        if self.user != nil {
            dispatch_async(dispatch_get_main_queue(),{
                var query = PFQuery(className:"Story")
                query.whereKey("user", equalTo: self.user)
                query.orderByDescending("upvotes")
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        // The find succeeded.
                        println("Successfully retrieved \(objects.count) events.")
                        self.stories = objects
                        self.storyTableView.reloadData()
                        self.refreshControl.endRefreshing()
                        if(GSProgressHUD.isVisible()) {
                            GSProgressHUD.dismiss()
                        }
                    } else {
                        // Log details of the failure
                        println("Error: \(error) \(error.userInfo!)")
                        self.refreshControl.endRefreshing()
                        if(GSProgressHUD.isVisible()) {
                            GSProgressHUD.dismiss()
                        }
                    }
                }
            })
        }
    }
    
    
    func displayCreateProfileViewController() {
        presentCreateProfileViewController()
    }
    
    func displayLoginViewController() {
        presentLoginViewController()
    }
    
    func displayUserProfileView(user: PFUser) {
        var profileVC : ProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as ProfileViewController
        profileVC.user = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func presentLoginViewController() {
        var loginViewController : PFLogInViewController = PFLogInViewController()
        loginViewController.delegate = self
        loginViewController.facebookPermissions = NSArray(array: ["friends_about_me"])
        loginViewController.fields = PFLogInFields.Twitter | PFLogInFields.Facebook | PFLogInFields.DismissButton
        
        
        var signUpViewController : PFSignUpViewController = PFSignUpViewController()
        signUpViewController.delegate = self
        
        loginViewController.signUpController = signUpViewController
        
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func presentCreateProfileViewController() {
        var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as CreateProfileViewController
        self.presentViewController(createProfileVC, animated: true, completion: nil)
        
    }
    
    
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        if ((username != nil && password != nil && countElements(username) != 0 && countElements(password) != 0) ) {
            return true
        }
        
        UIAlertView(title: "Missing Information", message: "Make sure you fill out all of the information", delegate: nil, cancelButtonTitle: "OK").show()
        
        return false
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.storyTableView.reloadData()
        profileTabBarItem!.enabled = true
        
        if PFUser.currentUser()["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as CreateProfileViewController
            self.presentViewController(createProfileVC, animated: true, completion: nil)
        } else {
            //            if self.creatingNewStory == true {
            //                var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as StoryViewController
            //                storyVC.newStory = true
            //                navigationController?.pushViewController(storyVC, animated: true)
            //            }
        }
        
    }
    
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Failed to log in")
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, shouldBeginSignUp info: [NSObject : AnyObject]!) -> Bool {
        var informationComplete : Bool = true
        
        for (key,value) in info {
            var field : NSString = info["key"] as NSString
            if (field.length == 0) {
                informationComplete = false
                break
            }
        }
        
        if (!informationComplete) {
            UIAlertView(title: "Missing Information", message: "Make sure you fill out all of the information", delegate: nil, cancelButtonTitle: "OK").show()
            
        }
        return informationComplete
        
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.storyTableView.reloadData()
        profileTabBarItem!.enabled = true
        
        if PFUser.currentUser()["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as CreateProfileViewController
            self.presentViewController(createProfileVC, animated: true, completion: nil)
        } else {
            //            if self.creatingNewStory == true {
            //                var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as StoryViewController
            //                storyVC.newStory = true
            //                navigationController?.pushViewController(storyVC, animated: true)
            //            }
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed the signupviewcontroller")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ProfileRankingTableViewCellToStoryVCSegue") {
            
            var storyVC : StoryViewController = segue.destinationViewController as StoryViewController
            var storyIndex = storyTableView!.indexPathForSelectedRow()?.row
            var selectedStory : PFObject?
            if stories != nil {
                selectedStory = stories![storyIndex!] as PFObject
                storyVC.story = selectedStory
                storyVC.storyCreated = true
            }
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
