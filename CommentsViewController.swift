//
//  CommentsViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/14/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, PBJVisionDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var createViewExpanded = false
    var createViews = []
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var profileTabBarItem : UITabBarItem?
//    var votedStories : NSMutableDictionary = [:]
    
    @IBOutlet weak var createViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userButton: UILabel!

    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    
    
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var cameraSendButton: UIButton!
    @IBOutlet weak var cameraFlashButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var holdToRecordLabel: UILabel!
    
    
    @IBOutlet var videoLongPressGestureRecognizer: UILongPressGestureRecognizer!

    
    @IBOutlet weak var newCommentButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        createView.hidden = true
        profileTabBarItem = self.tabBarController?.tabBar.items?[1] as UITabBarItem
        
        self.commentsTableView.tableHeaderView = UIView(frame: CGRectMake(0.0, 0.0, self.commentsTableView.bounds.size.width, 0.01))
        
        profileImageView.layer.cornerRadius = 31
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.layer.borderWidth = 2
        profileImageView.clipsToBounds = true

        
        
        createViews = [cameraContainer, textContainer, videoContainer]
        profileTabBarItem = self.tabBarController?.tabBar.items?[1] as UITabBarItem
        
//        updateVotingLabels()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func minimizeCreateView() {
        newCommentButton.enabled = true
        
        self.view.layoutIfNeeded()
        
        self.createViewTopConstraint.constant = -(screenSize.width + 46)
        //        createViewLeadingConstraint.constant = screenSize.width/4
        //        createViewTrailingConstraint.constant = screenSize.width/4
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.createView.hidden = true
                self.createViewExpanded = false
                self.newCommentButton!.title = "+ Comment"
        })
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
        
        
    }
    
    
    
    
    @IBAction func newCommentButtonWasTapped(sender: AnyObject) {
        if (PFUser.currentUser() == nil){
            presentLoginViewController()
        } else if (PFUser.currentUser() != nil && PFUser.currentUser()["profileName"] == nil) {
            presentCreateProfileViewController()
        } else {
            if createViewExpanded == false {
                expandCreateView()
            } else {
                minimizeCreateView()
            }
        }
    }
    
    func expandCreateView() {
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        self.createView.hidden = false
        self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        self.createViewTopConstraint.constant = 0
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
            }, completion: {
                (value: Bool) in
                self.createView.hidden = false
                self.newCommentButton!.title = "Cancel"
                self.createViewExpanded = true            })
        
//        if playingVideoCell != nil && playingVideoCell?.player?.rate == 1.0 {
//            playingVideoCell?.player?.pause()
//            playingVideoCell?.playButtonIconImageView.hidden = false
//        }
        
//        vision.cameraMode = PBJCameraMode.Photo
//        vision.captureSessionPreset = AVCaptureSessionPresetPhoto
        cameraSendButton.hidden = false
        cameraSendButton.enabled = true
        holdToRecordLabel.hidden = true
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
        
        
//        vision.startPreview()
        
        
    }
    
    func presentLoginViewController() {
        var loginViewController : CustomLoginViewController = CustomLoginViewController()
        loginViewController.delegate = self
        loginViewController.facebookPermissions = NSArray(array: ["friends_about_me"])
        loginViewController.fields = PFLogInFields.Twitter | PFLogInFields.Facebook | PFLogInFields.DismissButton
        
        
        var signUpViewController : CustomSignUpViewController = CustomSignUpViewController()
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
//        updateVotingLabels()
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
//        updateVotingLabels()
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
    
//    func updateVotingLabels() {
//        if PFUser.currentUser() != nil{
//            if PFUser.currentUser()["votedStories"] != nil {
//                self.votedStories = PFUser.currentUser()["votedStories"] as NSMutableDictionary
//                if self.story != nil {
//                    if votedStories[self.story!.objectId] != nil {
//                        if self.story != nil{
//                            if votedStories[self.story!.objectId] as Int == 1 {
//                                storyUpVoted = true
//                                upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
//                                pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
//                            } else if votedStories[self.story!.objectId] as Int == -1 {
//                                storyDownVoted = true
//                                downVoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
//                                pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    
    
    @IBAction func textButtonWasTapped(sender: AnyObject) {
    }
    
    @IBAction func cameraButtonWasTapped(sender: AnyObject) {
    }
    
    
    @IBAction func videoButtonWasTapped(sender: AnyObject) {
    }
    
    
    
    @IBAction func cameraSendButtonWasTapped(sender: AnyObject) {
    }

    @IBAction func cameraFlashButtonWasTapped(sender: AnyObject) {
    }
    
    @IBAction func cameraSwitchButtonWasTapped(sender: AnyObject) {
    }
    
    
    @IBAction func videoLongPressGestureRecognizerWasPressed(sender: AnyObject) {
    }
    
    
}
