//
//  AddAuthorViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/20/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit



class AddAuthorViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userAlreadyAddedAlertTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var userTableViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var userSearchBar: UISearchBar!
    @IBOutlet var tableViewTapGestureRecognizer: UITapGestureRecognizer!
    var maxReached = true
    var currentOffset = 0
    var users = []
    var requestingUsers = false
    var story : PFObject?
    var userAlreadyAddedAlertVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userSearchBar.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        self.userTableView.delegate = self
        self.userTableView.dataSource = self
        if (self.userTableView.respondsToSelector(Selector("layoutMargins"))) {
            self.userTableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        if self.story != nil {
            if self.story!["authors"] != nil {
                users = self.story!["authors"] as NSArray
            } else {
                users = [PFUser.currentUser()]
            }
            userTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedUser = users[indexPath.row] as PFUser
        var selectedUserProfileName = selectedUser["profileName"] as String
        if self.story != nil {
            var storyUser = self.story!["user"] as PFUser
            storyUser.fetchIfNeededInBackgroundWithBlock{
                (post: PFObject!, error: NSError!) -> Void in
                var storyUserProfileName = storyUser["profileName"] as String
                if selectedUserProfileName == storyUserProfileName {
                    if self.userAlreadyAddedAlertVisible == false {
                        self.displayAlreadyAddedAlert()
                    }
                } else {
                    var cell = self.userTableView.cellForRowAtIndexPath(indexPath) as UserTableViewCell
                    if  self.story!["authors"] == nil {
                        var invitedAuthorsDict = NSMutableDictionary()
//                        invitedAuthorsDict[storyUserProfileName] = 1
//                        invitedAuthorsDict[selectedUserProfileName] = 0
//                        self.story!["invitedAuthors"] = invitedAuthorsDict as NSDictionary
                        self.story!["authors"] = [self.story!["user"], selectedUser]
                        
                        cell.userAddedIndicator.alpha = 0
                        cell.userAddedIndicator.hidden = false
                        UIView.animateWithDuration(0.5, animations: {
                            cell.userAddedIndicator.alpha = 1
                            }, completion: {
                                (value: Bool) in
                                self.story!.saveInBackground()
                                self.dismissViewControllerAnimated(true, completion: {})
                        })
                        
                        
                        

                    } else {
                        var storyAuthors = self.story!["authors"] as NSArray
                        var matchCount = 0
                        for author in storyAuthors {
                            if selectedUser.objectId == author.objectId {
                                matchCount += 1
                            }
                        }
                        if matchCount > 0 {
                            if self.userAlreadyAddedAlertVisible == false {
                                self.displayAlreadyAddedAlert()
                            }
                        } else {
                            var temporaryAuthorsArray = NSMutableArray(array: storyAuthors)
                            temporaryAuthorsArray.addObject(selectedUser)
                            self.story!["authors"] = temporaryAuthorsArray as NSArray
                            cell.userAddedIndicator.alpha = 0
                            cell.userAddedIndicator.hidden = false
                            UIView.animateWithDuration(0.5, animations: {
                                cell.userAddedIndicator.alpha = 1
                                }, completion: {
                                    (value: Bool) in
                                    self.story!.saveInBackground()
                                    self.dismissViewControllerAnimated(true, completion: {})
                            })

                        }
                        
                    }
                }
            }
            
        }
    }


    func displayAlreadyAddedAlert() {
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        
        self.userAlreadyAddedAlertTopConstraint.constant = 0
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
            }, completion: {
                (value: Bool) in
                self.userAlreadyAddedAlertVisible = true})
    }
    
    func dismissAlreadyAddedAlert() {
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        
        self.userAlreadyAddedAlertTopConstraint.constant = -44
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
            }, completion: {
                (value: Bool) in
                self.userAlreadyAddedAlertVisible = false})
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeButtonWasTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

    @IBAction func tableViewTapGestureRecognizerWasTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.tableViewTapGestureRecognizer.enabled = false
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.tableViewTapGestureRecognizer.enabled = true
        var searchBarTextField : UITextField = UITextField()
//        for subview in searchBar.subviews {
//            for secondLevelSubView in subview.subviews{
//                if secondLevelSubView.isKindOfClass(UITextField){
//                    searchBarTextField = secondLevelSubView as UITextField
//                    break
//                }
//            }
//        }
//        searchBarTextField.enablesReturnKeyAutomatically = false
    }
    
    func keyBoardWillChange(notification: NSNotification) {
        // Adjusts size of text view to scroll when keyboard is up
        var keyBoardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        self.view.convertRect(keyBoardRect, fromView: nil)
        
        var tableViewRect : CGRect = self.userTableView.frame
        
        self.view.layoutIfNeeded()
        
        if CGFloat(tableViewRect.origin.y) + CGFloat(tableViewRect.height) > CGFloat(keyBoardRect.origin.y) {
            println("Keyboard Rect: \(keyBoardRect)")
            println("User Table View Rect: \(tableViewRect)")
            self.userTableViewBottomConstraint.constant = CGFloat(keyBoardRect.height)
        } else {
            self.userTableViewBottomConstraint.constant = 0
        }
        
        UIView.animateWithDuration(0.1, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == userTableView.numberOfRowsInSection(0)-1 && maxReached == false {
            var cell = tableView.dequeueReusableCellWithIdentifier("UserSpinnerCell") as UITableViewCell
            if (cell.respondsToSelector(Selector("layoutMargins"))) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            return cell
        } else {
            var user = users[indexPath.row] as PFObject
            var cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell") as UserTableViewCell
            if (cell.respondsToSelector(Selector("layoutMargins"))) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            cell.populateCellWithUser(user)
            var matchCount = 0
            if user.objectId == (story!["user"] as PFObject).objectId {
                cell.userAddedIndicator.hidden = false
            } else {
                if self.story!["authors"] != nil {
                    for author in self.story!["authors"] as NSArray {
                        if user.objectId == author.objectId {
                            matchCount += 1
                        }
                    }
                    if matchCount > 0 {
                        cell.userAddedIndicator.hidden = false
                    }
                }
            }
            
            return cell
        }
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if maxReached == true {
            return self.users.count
        } else {
            return self.users.count + 1
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        println("Search button pressed")
        self.requestUsers(self, offset: 0)
        self.view.endEditing(true)
        self.tableViewTapGestureRecognizer.enabled = false
    }
    
    func requestUsers(sender:AnyObject, offset: Int)  {
        self.maxReached = false
        
        
        var query = PFUser.query()
        println("\(self.userSearchBar.text.lowercaseString)")
        var string = self.userSearchBar.text as String
        query.whereKey("canonicalProfileName", containsString: string.lowercaseString)
//            query.whereKey("canonicalProfileName", equalTo: string.lowercaseString)
        query.orderByAscending("profileName")
        query.limit = 20
        if offset == 0 {
            self.users = []
            self.currentOffset = 0
        }
        print("Query skipping \(self.currentOffset) users")
        query.skip = self.currentOffset
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects.count) users.")
            
                if objects.count == 0 || objects.count < 20 {
                    self.maxReached = true
                }
                
                var temporaryArray : NSMutableArray = NSMutableArray(array: self.users)
                temporaryArray.addObjectsFromArray(objects)
                self.users = temporaryArray
                self.currentOffset = self.users.count
                
                self.userTableView.reloadData()
                self.requestingUsers = false
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")

            }
        }
        
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        var actualPosition :CGFloat = scrollView.contentOffset.y
        var contentHeight : CGFloat = scrollView.contentSize.height - 750
        
        //        println("Actual Position: \(actualPosition), Content Height: \(contentHeight)")
        if (actualPosition >= contentHeight && users.count > 0) {
            
            if self.maxReached == false && self.requestingUsers == false {
                requestingUsers = true
                requestUsers(self, offset: currentOffset)
                self.userTableView.reloadData()
            }
        }
        
    }

}
