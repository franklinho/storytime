//
//  RankingViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var stories : NSArray?
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var votedStories : NSMutableDictionary = [:]
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    @IBOutlet weak var rankingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        

        
        rankingTableView.backgroundView = nil
        rankingTableView.backgroundView?.backgroundColor = UIColor(red: 41.0/255.0, green: 37.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        rankingTableView.delegate = self
        rankingTableView.dataSource = self
        if (PFUser.currentUser() == nil){
            logOutButton.enabled = false
        }
        
        self.rankingTableView.rowHeight = self.screenSize.width
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stories != nil {
            return stories!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = rankingTableView.dequeueReusableCellWithIdentifier("RankingTableViewCell") as RankingTableViewCell
        cell.upvoteButton.setImage(UIImage(named: "up_icon_white.png"), forState: UIControlState.Normal)
        cell.downvoteButton.setImage(UIImage(named: "down_icon_white.png"), forState: UIControlState.Normal)
        cell.pointsLabel.textColor = UIColor.whiteColor()
        
        var story : PFObject?
        if stories != nil {
            story = stories![indexPath.row] as? PFObject
            cell.titleLabel.text = story!["title"] as? String
            var storyUser : PFUser = story!["user"] as PFUser
            storyUser.fetchIfNeeded()
            var profileName : String = storyUser["profileName"] as String
            var profileImageFile = storyUser["profileImage"] as PFFile
            profileImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    let image = UIImage(data:imageData)
                    cell.profileImageView.image = image
                }
            }
   
            cell.userLabel.text = profileName
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func newStoryButtonWasTapped(sender: AnyObject) {
        if (PFUser.currentUser() == nil){
            var loginViewController : PFLogInViewController = PFLogInViewController()
            loginViewController.delegate = self
            loginViewController.facebookPermissions = NSArray(array: ["friends_about_me"])
            loginViewController.fields = PFLogInFields.Twitter | PFLogInFields.Facebook | PFLogInFields.DismissButton
            
            
            var signUpViewController : PFSignUpViewController = PFSignUpViewController()
            signUpViewController.delegate = self
            
            loginViewController.signUpController = signUpViewController
            
            self.presentViewController(loginViewController, animated: true, completion: nil)
        } else if (PFUser.currentUser() != nil && PFUser.currentUser()["profileName"] == nil) {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as CreateProfileViewController
            self.presentViewController(createProfileVC, animated: true, completion: nil)

        } else {
            var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as StoryViewController
            storyVC.newStory = true
            navigationController?.pushViewController(storyVC, animated: true)
        }
        
        
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
        logOutButton.enabled = true
        var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as StoryViewController
        storyVC.newStory = true
        navigationController?.pushViewController(storyVC, animated: true)
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
    
    override func viewDidAppear(animated: Bool) {
        requestStories()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        logOutButton.enabled = true
        var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as StoryViewController
        storyVC.newStory = true
        navigationController?.pushViewController(storyVC, animated: true)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed the signupviewcontroller")
    }
    
    @IBAction func logOutButtonWasTapped(sender: AnyObject) {
        PFUser.logOut()
        UIAlertView(title: "Logged Out", message: "You have successfully logged out.", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func requestStories() {
        dispatch_async(dispatch_get_main_queue(),{
            var query = PFQuery(className:"Story")
            query.orderByDescending("upvotes")
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects.count) events.")
                    self.stories = objects
                    self.rankingTableView.reloadData()
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            var title = object["title"]
                            println("Object ID: \(object.objectId), Timestamp: \(object.createdAt?), Text: \(title)")
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error.userInfo!)")
                }
            }
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RankingTableViewCellToStoryVCSegue") {
            
            var storyVC : StoryViewController = segue.destinationViewController as StoryViewController
            var storyIndex = rankingTableView!.indexPathForSelectedRow()?.row
            var selectedStory : PFObject?
            if stories != nil {
                selectedStory = stories![storyIndex!] as PFObject
                storyVC.story = selectedStory
                storyVC.storyCreated = true
            }
            
        }
    }

        
}
