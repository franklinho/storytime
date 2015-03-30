//
//  RankingViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = rankingTableView.dequeueReusableCellWithIdentifier("RankingTableViewCell") as RankingTableViewCell
        
        cell.rankLabel.text = "\(indexPath.row+1)"
        cell.titleLabel.text = "This is the #\(indexPath.row+1) story"
        
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
    
        
}
