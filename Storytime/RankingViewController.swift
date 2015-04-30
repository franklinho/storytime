//
//  RankingViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, RankingTableViewCellDelegate, UISearchBarDelegate {

    var stories = []
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var votedStories : NSMutableDictionary = [:]
    var creatingNewStory = false
    var refreshControl : UIRefreshControl!
    var profileTabBarItem : UITabBarItem?
    var currentOffset = 0
    var maxReached = false
    var requestingObjects = false
    @IBOutlet var viewTapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    @IBOutlet weak var rankingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTapGestureRecognizer.enabled = false
        searchBar.delegate = self
        profileTabBarItem = self.tabBarController?.tabBar.items?[1] as! UITabBarItem
        
        
        if PFUser.currentUser() == nil {
            logOutButton.title = "Log In"
            profileTabBarItem!.enabled = false
        }
        
        if PFUser.currentUser() != nil {
            PFInstallation.currentInstallation()["user"] = PFUser.currentUser()!.objectId!
            PFInstallation.currentInstallation().saveInBackground()
        }


        // Do any additional setup after loading the view.
        
        if PFUser.currentUser() != nil && PFUser.currentUser()?["profileName"] != nil && PFUser.currentUser()?["canonicalProfileName"] == nil {
            PFUser.currentUser()!["canonicalProfileName"] = (PFUser.currentUser()?["profileName"] as! String).lowercaseString
            PFUser.currentUser()!.saveInBackground()
        }

        
        rankingTableView.backgroundView = nil
        rankingTableView.backgroundView?.backgroundColor = UIColor(red: 41.0/255.0, green: 37.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        rankingTableView.delegate = self
        rankingTableView.dataSource = self
        
        self.rankingTableView.rowHeight = self.screenSize.width
        
        if (self.rankingTableView.respondsToSelector(Selector("layoutMargins"))) {
            self.rankingTableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        
        
        // Add pull to refresh to the tableview
        self.refreshControl = UIRefreshControl()
        var pullToRefreshString = "Pull to refresh"
        var pullToRefreshAttributedString : NSMutableAttributedString = NSMutableAttributedString(string: pullToRefreshString)
        pullToRefreshAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(pullToRefreshString)))
        self.refreshControl.attributedTitle = pullToRefreshAttributedString
        self.refreshControl.addTarget(self, action: "refreshStories", forControlEvents: UIControlEvents.ValueChanged)
        self.rankingTableView.addSubview(refreshControl)

//        GSProgressHUD.show()
        self.currentOffset = 0
        requestStories(self,offset: currentOffset)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Table returning \(self.stories.count) cells")
        if maxReached == true {
            return self.stories.count
        } else {
            return self.stories.count + 1
        }
        
        
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == rankingTableView.numberOfRowsInSection(0)-1 && maxReached == false {
            var cell = tableView.dequeueReusableCellWithIdentifier("SpinnerCell") as! UITableViewCell
            if (cell.respondsToSelector(Selector("layoutMargins"))) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            return cell
        } else {
            var cell = rankingTableView.dequeueReusableCellWithIdentifier("RankingTableViewCell") as! RankingTableViewCell
            if (cell.respondsToSelector(Selector("layoutMargins"))) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            cell.prepareForReuse()
            cell.delegate = self
            
            var story : PFObject?
            
            if stories.count > 0 {
                story = stories[indexPath.row] as? PFObject
                cell.story = story
                cell.titleLabel.text = story!["title"] as? String
                var storyUser : PFUser = story!["user"] as! PFUser
                storyUser.fetchIfNeededInBackgroundWithBlock {
                    (post, error) -> Void in
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
                                cell.profileImageView.hidden = true
                                cell.profileImageView.image = image
                                cell.profileImageView.alpha = 0
                                cell.profileImageView.hidden = false
                                UIView.animateWithDuration(0.3, animations: {
                                    cell.profileImageView.alpha = 1
                                    }, completion: {
                                        (value: Bool) in
                                        
                                })
                            }
                        }
                    }
                }
                
                
                if story!["points"] == nil {
                    var upvotes = story!["upvotes"] as! Int
                    var downvotes = story!["downvotes"] as! Int
                    story!["points"] = upvotes - downvotes
                    story?.saveInBackground()
                }
                
                if story!["points"] != nil {
                    var points = story!["points"] as? Int
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
                        println("Voted Stories: \(self.votedStories)")
                        if votedStories[story!.objectId!] != nil{
                            if votedStories[story!.objectId!] as! Int == 1 {
                                cell.storyUpVoted = true
                                cell.upvoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                                cell.pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                            } else if votedStories[story!.objectId!] as! Int == -1 {
                                cell.storyDownVoted = true
                                cell.downvoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
                                cell.pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                            } else {
                                cell.storyUpVoted = false
                                cell.storyDownVoted = false
                            }
                        } else {
                            cell.storyUpVoted = false
                            cell.storyDownVoted = false
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
                            cell.previewImageView.alpha = 0
                            cell.previewImageView.hidden = false
                            UIView.animateWithDuration(0.3, animations: {
                                cell.previewImageView.alpha = 1
                                }, completion: {
                                    (value: Bool) in
                                    
                            })
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
                            cell.previewImageView.alpha = 0
                            cell.previewImageView.hidden = false
                            UIView.animateWithDuration(0.3, animations: {
                                cell.previewImageView.alpha = 1
                                }, completion: {
                                    (value: Bool) in
                                    
                            })
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
            
            println("Story Title: \(cell.titleLabel.text), objectID \(cell.story!.objectId), upvoted: \(cell.storyUpVoted), downvoted: \(cell.storyDownVoted)")
            
            return cell
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
        self.presentViewController(createProfileVC, animated: true, completion: nil)

    }

    @IBAction func newStoryButtonWasTapped(sender: AnyObject) {
        creatingNewStory = true
        if (PFUser.currentUser() == nil){
            presentLoginViewController()
        } else if (PFUser.currentUser() != nil && PFUser.currentUser()!["profileName"] == nil) {
            presentCreateProfileViewController()
        } else {
            var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as! StoryViewController
            storyVC.newStory = true
            navigationController?.pushViewController(storyVC, animated: true)
        }
    
    
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
        self.rankingTableView.reloadData()
        logOutButton.title = "Log Out"
        profileTabBarItem!.enabled = true
        
        PFInstallation.currentInstallation()["user"] = PFUser.currentUser()
        PFInstallation.currentInstallation().saveInBackground()
        
        if PFUser.currentUser()!["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
            self.presentViewController(createProfileVC, animated: true, completion: nil)
        } else {
            if self.creatingNewStory == true {
                var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as! StoryViewController
                storyVC.newStory = true
                navigationController?.pushViewController(storyVC, animated: true)
            }
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
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            logOutButton.title = "Log Out"
        } else {
            logOutButton.title = "Log In"
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.rankingTableView.reloadData()
        logOutButton.title = "Log Out"
        profileTabBarItem!.enabled = true
        PFInstallation.currentInstallation()["user"] = PFUser.currentUser()
        PFInstallation.currentInstallation().saveInBackground()
        if PFUser.currentUser()!["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
            self.presentViewController(createProfileVC, animated: true, completion: nil)
        } else {
            if self.creatingNewStory == true {
                var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as! StoryViewController
                storyVC.newStory = true
                navigationController?.pushViewController(storyVC, animated: true)
            }
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed the signupviewcontroller")
    }
    
    @IBAction func logOutButtonWasTapped(sender: AnyObject) {
        self.creatingNewStory = false
        if PFUser.currentUser() != nil {
            PFUser.logOut()
            UIAlertView(title: "Logged Out", message: "You have successfully logged out.", delegate: nil, cancelButtonTitle: "OK").show()
            self.votedStories = [:] as NSMutableDictionary
            self.rankingTableView.reloadData()
            self.logOutButton.title = "Log In"
            profileTabBarItem!.enabled = false
        } else {
            presentLoginViewController()
        }
        
    }
    func refreshStories() {

        requestStories(self, offset: 0)
    }
    
    func requestStories(sender:AnyObject, offset: Int) {
        maxReached = false
        
        dispatch_async(dispatch_get_main_queue(),{
            var query = PFQuery(className:"Story")
            if self.searchBar.text != "" {
                var string = self.searchBar.text as String
                query.whereKey("title", matchesRegex: string, modifiers: "i")
            }
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
                    
                    var temporaryArray : NSMutableArray = NSMutableArray(array: self.stories)
                    temporaryArray.addObjectsFromArray(objects!)
                    self.stories = temporaryArray
                    self.currentOffset = self.stories.count
                    
                    self.rankingTableView.reloadData()
//                    print("This is a list of all the stories \(self.stories)")
                    self.refreshControl.endRefreshing()
//                    if(GSProgressHUD.isVisible()) {
//                        GSProgressHUD.dismiss()
//                    }
                    self.requestingObjects = false
                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error!.userInfo!)")
                    self.refreshControl.endRefreshing()
//                    if(GSProgressHUD.isVisible()) {
//                        GSProgressHUD.dismiss()
//                    }
                }
            }
        })
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RankingTableViewCellToStoryVCSegue") {
            
            var storyVC : StoryViewController = segue.destinationViewController as! StoryViewController
            var storyIndex = rankingTableView!.indexPathForSelectedRow()?.row
            var selectedStory : PFObject?
            selectedStory = stories[storyIndex!] as! PFObject
            storyVC.story = selectedStory
            storyVC.storyCreated = true
        }
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        GSProgressHUD.dismiss()
//    }
    
    @IBAction func viewWasTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.viewTapGestureRecognizer.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.rankingTableView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        var actualPosition :CGFloat = scrollView.contentOffset.y
        var contentHeight : CGFloat = scrollView.contentSize.height - 750
        
//        println("Actual Position: \(actualPosition), Content Height: \(contentHeight)")
        if (actualPosition >= contentHeight && stories.count > 0) {
            
            if self.maxReached == false && self.requestingObjects == false {
                requestingObjects = true
                requestStories(self, offset: currentOffset)
                self.rankingTableView.reloadData()
            }
        }
        
    }
    


    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        println("Search button pressed")
        self.refreshStories()
        self.view.endEditing(true)
        self.viewTapGestureRecognizer.enabled = false
    }
    
    // Allows search bar to search on empty strings
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.viewTapGestureRecognizer.enabled = true
        var searchBarTextField : UITextField = UITextField()
        for subview in searchBar.subviews {
            for secondLevelSubView in subview.subviews{
                if secondLevelSubView.isKindOfClass(UITextField){
                    searchBarTextField = secondLevelSubView as! UITextField
                    break
                }
            }
        }
        searchBarTextField.enablesReturnKeyAutomatically = false
    }
    
    // dismisses keyboard when you click cancel
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        searchBar.text = ""
        self.view.endEditing(true)
        self.viewTapGestureRecognizer.enabled = false
    }
    
    func displayCommentsViewFor(story: PFObject) {
        var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as! StoryViewController
        storyVC.story = story
        storyVC.storyCreated = true
        navigationController?.pushViewController(storyVC, animated: true)
        storyVC.displayStoryComments()
    }


        
}
