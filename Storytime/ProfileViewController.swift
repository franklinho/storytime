//
//  ProfileViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/8/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RankingTableViewCellDelegate,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CreateProfileViewControllerDelegate {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var profileImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var followButton: UIButton!
    var stories = []
    var votedStories : NSMutableDictionary = [:]
    var user : PFUser?
    @IBOutlet weak var profileImageView: UIImageView!
    var currentOffset = 0
    var maxReached = false
    var requestingObjects = false
    var menu = false
    var menuButton : UIBarButtonItem?
    
    @IBOutlet weak var noStoriesLabel: UILabel!
    @IBOutlet weak var storyTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    var refreshControl : UIRefreshControl!
    var hamburgerVC : HamburgerViewController?
    var following = false
//    var profileTabBarItem : UITabBarItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hamburgerVC = self.parentViewController!.parentViewController as! HamburgerViewController

        profileImageLeadingConstraint.constant = (screenSize.width - 256)/2
        
        if menu == true {
            self.menuButton = UIBarButtonItem(image: UIImage(named:"menuIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("didTapMenuButton"))
            navigationItem.leftBarButtonItem = menuButton
        }
        
        
//        profileTabBarItem = self.tabBarController?.tabBar.items?[1] as! UITabBarItem
        followButton.layer.cornerRadius = 22
        followButton.clipsToBounds = true
        
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.layer.borderWidth = 4
        profileImageView.clipsToBounds = true
        
        
        
        

        // Do any additional setup after loading the view.
        storyTableView.delegate = self
        storyTableView.dataSource = self
        if (self.storyTableView.respondsToSelector(Selector("layoutMargins"))) {
            self.storyTableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        storyTableView.rowHeight = self.screenSize.width
//        refreshStories()
//        GSProgressHUD.show()
        
        // Add pull to refresh to the tableview
        self.refreshControl = UIRefreshControl()
        var pullToRefreshString = "Pull to refresh"
        var pullToRefreshAttributedString : NSMutableAttributedString = NSMutableAttributedString(string: pullToRefreshString)
        pullToRefreshAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(pullToRefreshString)))
        self.refreshControl.attributedTitle = pullToRefreshAttributedString
        self.refreshControl.addTarget(self, action: "refreshStories", forControlEvents: UIControlEvents.ValueChanged)
        self.storyTableView.addSubview(refreshControl)

        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == storyTableView.numberOfRowsInSection(0)-1 && maxReached == false {
            var cell = tableView.dequeueReusableCellWithIdentifier("SpinnerCell") as! UITableViewCell
            if (cell.respondsToSelector(Selector("layoutMargins"))) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            return cell
        } else {
            var cell = storyTableView.dequeueReusableCellWithIdentifier("RankingTableViewCell") as! RankingTableViewCell
            if (cell.respondsToSelector(Selector("layoutMargins"))) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            cell.upvoteButton.setImage(UIImage(named: "up_icon_white.png"), forState: UIControlState.Normal)
            cell.downvoteButton.setImage(UIImage(named: "down_icon_white.png"), forState: UIControlState.Normal)
            cell.pointsLabel.textColor = UIColor.whiteColor()
            cell.delegate = self
            
            var story : PFObject?
            
            if stories.count > 0 {
                story = stories[indexPath.row] as? PFObject
                cell.story = story
                cell.titleLabel.text = story!["title"] as? String
                var storyUser : PFUser = story!["user"] as! PFUser
                storyUser.fetchIfNeeded()
                if storyUser["profileName"] != nil {
                    var profileName : String = storyUser["profileName"] as! String
                    cell.userButton.setTitle(profileName, forState: UIControlState.Normal)
                }
                
                if storyUser["profileImage"] != nil {
                    var profileImageFile = storyUser["profileImage"] as! PFFile
                    profileImageFile.getDataInBackgroundWithBlock {
                        (imageData, error) -> Void in
                        if error == nil {
                            let image = UIImage(data:imageData!)
                            cell.profileImageView.image = image
                        }
                    }
                }
                
                
                
                var upvotes = story!["upvotes"] as? Int
                var downvotes = story!["downvotes"] as? Int
                if story!["points"] == nil {
                    story!["points"] = upvotes! - downvotes!
                    story?.saveInBackground()
                }
                
                if story!["points"] != nil {
                    var points = story!["points"]
                    cell.pointsLabel.text = "\(points!)"
                }
                
                if story!["commentsCount"] != nil {
                    var commentsCount = story!["commentsCount"] as! Int
                    cell.commentsButton.setTitle("  \(commentsCount) Comments  ", forState: UIControlState.Normal)
                } else {
                    cell.commentsButton.setTitle("  0 Comments  ", forState: UIControlState.Normal)
                }
                
                
                
                if PFUser.currentUser() != nil{
                    if PFUser.currentUser()!["votedStories"] != nil {
                        self.votedStories = PFUser.currentUser()!["votedStories"] as! NSMutableDictionary
                        if votedStories[story!.objectId!] != nil{
                            if votedStories[story!.objectId!] as! Int == 1 {
                                cell.storyUpVoted = true
                                cell.upvoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                                cell.pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                            } else if votedStories[story!.objectId!] as! Int == -1 {
                                cell.storyDownVoted = true
                                cell.downvoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
                                cell.pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                            }
                        }
                    }
                }
                
                
                
                cell.previewImageView.hidden = true
                if story!["thumbnailImage"] != nil {
                    let imageFile = story!["thumbnailImage"] as! PFFile
                    imageFile.getDataInBackgroundWithBlock {
                        (imageData, error) -> Void in
                        if error == nil {
                            let image = UIImage(data:imageData!)
                            cell.previewImageView.image = image
                            cell.previewImageView.hidden = false
                            cell.thumbnailTextLabel.hidden = true
                        }
                    }
                } else if story!["thumbnailVideoScreenCap"] != nil {
                    let imageFile = story!["thumbnailVideoScreenCap"] as! PFFile
                    imageFile.getDataInBackgroundWithBlock {
                        (imageData, error) -> Void in
                        if error == nil {
                            let image = UIImage(data:imageData!)
                            cell.previewImageView.image = image
                            cell.previewImageView.hidden = false
                            cell.thumbnailTextLabel.hidden = true
                        }
                    }
                } else if story!["thumbnailText"] != nil {
                    cell.previewImageView.hidden = true
                    cell.thumbnailTextLabel.hidden = false
                    cell.thumbnailTextLabel.text = story!["thumbnailText"] as! String
                }
                
                cell.rankLabel.text = "\(indexPath.row+1)."
            }
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Table returning \(self.stories.count) cells")
        if maxReached == true {
            return self.stories.count
        } else {
            return self.stories.count + 1
        }

        
    }
    
    func refreshStories() {
        self.stories = []
        requestStories(self, offset: 0)
    }
    
    func requestStories(sender:AnyObject, offset: Int) {
        maxReached = false
        
        dispatch_async(dispatch_get_main_queue(),{
            var query = PFQuery(className:"Story")
            query.whereKey("user", equalTo: self.user!)
            query.orderByDescending("points")
            query.addDescendingOrder("createdAt")
            query.limit = 10
            if offset == 0 {
                self.stories = []
                self.currentOffset = 0
            }
            print("Query skipping \(self.currentOffset) stories")
            query.skip = self.currentOffset
            query.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects!.count) events.")
//                    for object in objects {
//                        var objectTitle = object["title"]
//                        println("This is the object's title: \(objectTitle!))")
//                    }
                    if objects!.count == 0 || objects!.count < 10 {
                        self.maxReached = true
                    }
                    
                    if objects!.count == 0 {
                        self.noStoriesLabel.hidden = false
                    } else {
                        self.noStoriesLabel.hidden = true
                    }
                    
                    var temporaryArray : NSMutableArray = NSMutableArray(array: self.stories)
                    temporaryArray.addObjectsFromArray(objects!)
                    self.stories = temporaryArray
                    self.currentOffset = self.stories.count
                    
                    self.storyTableView.reloadData()
//                    print("This is a list of all the stories \(self.stories)")
                    self.refreshControl.endRefreshing()
                    //                    if(GSProgressHUD.isVisible()) {
                    //                        GSProgressHUD.dismiss()
                    //                    }
                    self.requestingObjects = false
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                    self.refreshControl.endRefreshing()
                    //                    if(GSProgressHUD.isVisible()) {
                    //                        GSProgressHUD.dismiss()
                    //                    }
                }
            }
        })
        
    }
    
    
    func displayCreateProfileViewController() {
        presentCreateProfileViewController()
    }
    
    func displayLoginViewController() {
        presentLoginViewController()
    }
    
    func displayUserProfileView(user: PFUser) {
        var profileVC : ProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        profileVC.user = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func presentLoginViewController() {
        var loginViewController : CustomLoginViewController = CustomLoginViewController()
        loginViewController.delegate = self
        loginViewController.facebookPermissions = NSArray(array: ["public_profile","user_friends"]) as [AnyObject]
        loginViewController.fields = PFLogInFields.Twitter | PFLogInFields.Facebook | PFLogInFields.DismissButton
//        loginViewController.fields = PFLogInFields.Twitter | PFLogInFields.DismissButton
        
        
        var signUpViewController : CustomSignUpViewController = CustomSignUpViewController()
        signUpViewController.delegate = self
        
        loginViewController.signUpController = signUpViewController
        
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func presentCreateProfileViewController() {
        var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        createProfileVC.delegate = self
        self.presentViewController(createProfileVC, animated: true, completion: nil)
        
    }
    
    func didCreateProfile() {
        var navVC = self.parentViewController as! UINavigationController
        var hamburgerVC = navVC.parentViewController as! HamburgerViewController
        hamburgerVC.refreshLoginLabels()
    }
    
    
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        if ((username != nil && password != nil && count(username) != 0 && count(password) != 0) ) {
            return true
        }
        
        UIAlertView(title: "Missing Information", message: "Make sure you fill out all of the information", delegate: nil, cancelButtonTitle: "OK").show()
        
        return false
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.storyTableView.reloadData()
//        hamburgerVC!.profileButton.enabled = true
        hamburgerVC!.refreshLoginLabels()
        PFInstallation.currentInstallation()["user"] = user
        PFInstallation.currentInstallation().saveInBackground()
        if PFUser.currentUser()!["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
            createProfileVC.delegate = self
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
            var field : NSString = info["key"] as! NSString
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
//        hamburgerVC!.profileButton.enabled = true
        hamburgerVC!.refreshLoginLabels()
        PFInstallation.currentInstallation()["user"] = user
        PFInstallation.currentInstallation().saveInBackground()
        if PFUser.currentUser()!["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
            createProfileVC.delegate = self
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
            
            var storyVC : StoryViewController = segue.destinationViewController as! StoryViewController
            var storyIndex = storyTableView!.indexPathForSelectedRow()?.row
            var selectedStory : PFObject?

            selectedStory = stories[storyIndex!] as! PFObject
            storyVC.story = selectedStory
            storyVC.storyCreated = true

            
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
    
    override func viewWillDisappear(animated: Bool) {
        GSProgressHUD.dismiss()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        var actualPosition :CGFloat = scrollView.contentOffset.y
        var contentHeight : CGFloat = scrollView.contentSize.height - 750
        
        //        println("Actual Position: \(actualPosition), Content Height: \(contentHeight)")
        if (actualPosition >= contentHeight && stories.count > 0) {
            
            if self.maxReached == false && self.requestingObjects == false {
                requestingObjects = true
                self.requestStories(self, offset: currentOffset)
                self.storyTableView.reloadData()
            }
        }
        
    }
    
    func displayCommentsViewFor(story: PFObject) {
        var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as! StoryViewController
        storyVC.story = story
        storyVC.storyCreated = true
        navigationController?.pushViewController(storyVC, animated: true)
        storyVC.displayStoryComments()
    }

    func didTapMenuButton(){
        self.menuButtonWasTapped(self)
    }
    
    @IBAction func menuButtonWasTapped(sender: AnyObject) {
        if hamburgerVC!.hamburgerShowing == true {
            hamburgerVC!.hideHamburgerMenu()
        } else {
            hamburgerVC!.showHamburgerMenu()
        }
    }
    @IBAction func followButtonWasTapped(sender: AnyObject) {
        if self.following == false {
            if PFUser.currentUser() != nil {
                PFUser.currentUser()!.addUniqueObject(self.user!, forKey: "following")
                PFUser.currentUser()!.saveInBackgroundWithBlock({(success, error) -> Void in
                    if success {
                        self.following = true
                        self.sendPushNotificationToUser(self.user!)
                    } else {
                        println("There was an error: \(error!.description)")
                    }
                })
                self.followButton.setTitle("  Unfollow", forState: UIControlState.Normal)
                self.followButton.setImage(nil, forState: UIControlState.Normal)
                self.followButton.backgroundColor = UIColor.darkGrayColor()
                
            } else {
                self.presentLoginViewController()
            }
        } else {
            PFUser.currentUser()!.removeObject(self.user!, forKey: "following")
            PFUser.currentUser()!.saveInBackgroundWithBlock({(success, error) -> Void in
                if success {
                    self.following = false
                } else {
                    println("There was an error: \(error!.description)")
                }
            })
            self.followButton.setTitle("  Follow", forState: UIControlState.Normal)
            self.followButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Normal)
            self.followButton.backgroundColor = UIColor.purpleColor()
            
        }
        
    }
    
    func sendPushNotificationToUser(user : PFUser) {
        var pushQuery : PFQuery = PFInstallation.query()!
        pushQuery.whereKey("user", equalTo: user.objectId!)
        pushQuery.whereKey("followNotificationsOn", equalTo: true)
        var currentUserProfileName = PFUser.currentUser()!["profileName"]
        
        let data = [
            "alert" : "\(currentUserProfileName!) has started following you"
        ]
        let push = PFPush()
        //                                            push.setMessage("\(currentUserProfileName!) has added you to the story: \(storyTitle!)")
        push.setQuery(pushQuery)
        push.setData(data)
        push.sendPushInBackgroundWithBlock({
            (success, error) -> Void in
            if success == true {
                println("Push query successful")
            } else {
                println("Push encountered error: \(error!.description)")
            }
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.refreshStories()
        if user == nil {
            if PFUser.currentUser() != nil {
                user = PFUser.currentUser()
                self.followButton.hidden = true
                self.userNameTopConstraint.constant = 47
            } else {
                presentLoginViewController()
            }
        }
        
        if user != nil {
            usernameLabel.text = user!["profileName"] as! String
            if user!["profileImage"] != nil {
                var profileImageFile = user!["profileImage"] as! PFFile
                profileImageFile.getDataInBackgroundWithBlock {
                    (imageData, error) -> Void in
                    if error == nil {
                        let image = UIImage(data:imageData!)
                        self.profileImageView.image = image
                    }
                }
            }
            
            if PFUser.currentUser() != nil {
                if PFUser.currentUser()!["following"] != nil {
                    
                    var followCount = 0
                    if PFUser.currentUser()!["following"] != nil {
                        var followingArray = PFUser.currentUser()!["following"] as! Array<PFUser>
                        for followingUser : PFUser in followingArray {
                            if followingUser.objectId == self.user!.objectId {
                                followCount += 1
                            }
                        }
                    }
                    
                    if followCount > 0 {
                        self.followButton.setTitle("  Unfollow", forState: UIControlState.Normal)
                        self.followButton.setImage(nil, forState: UIControlState.Normal)
                        self.followButton.backgroundColor = UIColor.darkGrayColor()
                        self.following = true
                    }
                    
                }
            }
            
        }
    }
    
}
