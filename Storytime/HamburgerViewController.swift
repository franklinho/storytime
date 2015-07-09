//
//  HamburgerViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 5/1/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit



class HamburgerViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CreateProfileViewControllerDelegate, UIActionSheetDelegate {
    
    
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var createProfileButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet var contentViewTapGestureRecognizer: UITapGestureRecognizer!
    
    var sb : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    var viewControllers : [UIViewController]!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var mentionsButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    
    var hamburgerShowing : Bool = false
    
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil){
            if let oldVC = oldViewControllerOrNil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.view.removeFromSuperview()
                oldVC.removeFromParentViewController()
            }
            if let newVC = activeViewController {
                self.addChildViewController(newVC)
                newVC.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                newVC.view.frame = self.contentView.bounds
                self.contentView.addSubview(newVC.view)
                newVC.didMoveToParentViewController(self)
            }
        }
    }
    
    
    @IBAction func didSwipeLeft(sender: UISwipeGestureRecognizer) {
        if sender.state == .Ended {
            hideHamburgerMenu()
        }
    }
    
    func hideHamburgerMenu() {
        UIView.animateWithDuration(0.35, animations: {
            self.centerConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.hamburgerShowing = false
            self.contentViewTapGestureRecognizer.enabled = false
        })
        
    }
    
    func showHamburgerMenu() {
        UIView.animateWithDuration(0.35, animations: {
            self.centerConstraint.constant = -225
            self.view.layoutIfNeeded()
            self.hamburgerShowing = true
            self.contentViewTapGestureRecognizer.enabled = true
        })
    }
    
    @IBAction func didSwipeRight(sender: UISwipeGestureRecognizer) {
        
        if sender.state == .Ended {
            showHamburgerMenu()
        }
        
    }
    
    override func viewDidLoad() {
        self.profileButton.enabled = true
        var rankingVC : UINavigationController = sb.instantiateViewControllerWithIdentifier("RankingNavigationViewController") as! UINavigationController
        var profileVC : UINavigationController = sb.instantiateViewControllerWithIdentifier("ProfileNavigationViewController") as! UINavigationController
        var settingsVC : UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
        var feedbackVC : UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FeedbackNavigationController") as! UINavigationController
        
        
//        var mentionsVC : TwitterNavigationController  = sb.instantiateViewControllerWithIdentifier("StatusesViewController") as! TwitterNavigationController
//        mentionsVC.timelineStyle = "Mentions"
        
        viewControllers = [rankingVC,profileVC, settingsVC, feedbackVC]
        
        
        
        self.centerConstraint.constant = 0
        self.activeViewController = viewControllers.first
        
        
        self.refreshLoginLabels()
        
        
        
//        // Fade in images
//        UIView.animateWithDuration(0.5,
//            delay: 0.0,
//            options: nil,
//            animations: {
//                self.userImageView.alpha = 1.0
//                
//            },
//            completion: {
//                finished in
//        })
    }
    @IBAction func didTapButton(sender: UIButton) {
        if sender == redButton {
            self.activeViewController = viewControllers.first
            var currentVC = self.activeViewController as! UINavigationController
            currentVC.popToRootViewControllerAnimated(true)
            var rankingVC = currentVC.visibleViewController as! RankingViewController
            rankingVC.refreshStories()
        } else if sender == profileButton{
            if PFUser.currentUser() != nil {
                if PFUser.currentUser()!["profileName"] != nil {
                    var currentVC = self.activeViewController as! UINavigationController
                    currentVC.popToRootViewControllerAnimated(true)
                    
                    var navVC = viewControllers[1] as! UINavigationController
                    var profileVC = navVC.visibleViewController as! ProfileViewController
                    profileVC.menu = true
                    profileVC.user = PFUser.currentUser()
                    
                    self.activeViewController = navVC
                } else {
                    presentCreateProfileViewController()
                }
            } else {
                presentLoginViewController()
            }
        } else if sender == settingsButton{
            var currentVC = self.activeViewController as! UINavigationController
            currentVC.popToRootViewControllerAnimated(true)
            var settingsVC = viewControllers[2] as! UINavigationController
            self.activeViewController = settingsVC
        } else if sender == feedbackButton {
            var feedbackActionSheet = UIActionSheet()
            feedbackActionSheet.delegate = self
            feedbackActionSheet.title = "How do you feel about Storyweave?"
            feedbackActionSheet.addButtonWithTitle("Happy")
            feedbackActionSheet.addButtonWithTitle("Confused")
            feedbackActionSheet.addButtonWithTitle("Unhappy")
            feedbackActionSheet.addButtonWithTitle("Cancel")
            feedbackActionSheet.cancelButtonIndex = 3
            feedbackActionSheet.actionSheetStyle = UIActionSheetStyle.Automatic
            feedbackActionSheet.tag = 1
            feedbackActionSheet.showInView(self.view)
        } else {
            println("Unknown button")
        }

        
        UIView.animateWithDuration(0.35, animations: {
            self.centerConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.hamburgerShowing = false
        })
    }
    
    
    @IBAction func didTapContentView(sender: AnyObject) {
        hideHamburgerMenu()
    }
    
    @IBAction func createProfileButtonWasTapped(sender: AnyObject) {
        presentCreateProfileViewController()
    }
    @IBAction func loginButtonWasTapped(sender: AnyObject) {
        presentLoginViewController()
    }
    
    func refreshLoginLabels() {
        if PFUser.currentUser() != nil {
            var user = PFUser.currentUser()!
            self.logOutButton.hidden = false
            if user["profileName"] != nil {
                self.userImageView.hidden = false
                self.userNameLabel.hidden = false
                self.logInButton.hidden = true
                
                self.createProfileButton.hidden = true
                self.userNameLabel.text = PFUser.currentUser()!["profileName"] as? String
                self.userImageView.layer.cornerRadius = 24
                self.userImageView.layer.borderWidth = 2
                self.userImageView.layer.borderColor = UIColor.whiteColor().CGColor
                self.userImageView.clipsToBounds = true
                
                if user["profileImage"] != nil {
                    var profileImageFile = user["profileImage"] as! PFFile
                    profileImageFile.getDataInBackgroundWithBlock {
                        (imageData, error) -> Void in
                        if error == nil {
                            let image = UIImage(data:imageData!)
                            self.userImageView.image = image
                        }
                    }
                }
            } else {
                logInButton.hidden = true
                createProfileButton.hidden = false
                userImageView.hidden = true
                userNameLabel.hidden = true
            }
            
        } else {
            logInButton.hidden = false
            createProfileButton.hidden = true
            userImageView.hidden = true
            userNameLabel.hidden = true
            self.logOutButton.hidden = true
        }
    }
    
    
    @IBAction func logOutButtonWasTapped(sender: AnyObject) {
        PFUser.logOut()
        UIAlertView(title: "Logged Out", message: "You have successfully logged out.", delegate: nil, cancelButtonTitle: "OK").show()
        self.refreshLoginLabels()
        self.activeViewController = viewControllers.first
        
//        self.profileButton.enabled = false
        (self.activeViewController as! UINavigationController).popToRootViewControllerAnimated(true)
        
        (self.activeViewController as! UINavigationController).visibleViewController.viewDidLoad()
//        self.viewControllers[0] = sb.instantiateViewControllerWithIdentifier("ProfileNavigationViewController") as! UINavigationController
        
        hideHamburgerMenu()
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
    
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        if ((username != nil && password != nil && count(username) != 0 && count(password) != 0) ) {
            return true
        }
        
        UIAlertView(title: "Missing Information", message: "Make sure you fill out all of the information", delegate: nil, cancelButtonTitle: "OK").show()
        
        return false
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        refreshLoginLabels()
        profileButton.enabled = true
        
        PFInstallation.currentInstallation()["user"] = user
        PFInstallation.currentInstallation().saveInBackground()
        
        if PFUser.currentUser()!["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
            createProfileVC.delegate = self
            self.presentViewController(createProfileVC, animated: true, completion: nil)
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
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        refreshLoginLabels()
        profileButton.enabled = true
        
        PFInstallation.currentInstallation()["user"] = user
        PFInstallation.currentInstallation().saveInBackground()
        
        if PFUser.currentUser()!["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
            createProfileVC.delegate = self
            self.presentViewController(createProfileVC, animated: true, completion: nil)
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed the signupviewcontroller")
    }
    
    func didCreateProfile() {
        self.refreshLoginLabels()
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == 1 {
            var currentVC = self.activeViewController as! UINavigationController
            currentVC.popToRootViewControllerAnimated(true)
            var feedbackNav = viewControllers[3] as! UINavigationController
            var feedbackPage = feedbackNav.visibleViewController as! FeedbackViewController
            
            if (buttonIndex == 0) {
                feedbackPage.userSentiment = "happy"
                self.activeViewController = feedbackNav
            } else if (buttonIndex == 1) {
                feedbackPage.userSentiment = "confused"
                self.activeViewController = feedbackNav
            } else {
                feedbackPage.userSentiment = "unhappy"
                self.activeViewController = feedbackNav

            }
        }
    }

}

class RedViewController: UIViewController {
    override func loadView() {
        self.view = UIView(frame: CGRectZero)
        self.view.backgroundColor = UIColor.redColor()
    }
}

class BlueViewController: UIViewController {
    override func loadView() {
        self.view = UIView(frame: CGRectZero)
        self.view.backgroundColor = UIColor.blueColor()
    }
}
