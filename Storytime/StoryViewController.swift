//
//  StoryViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var newStory : Bool = false
    var storyCreated : Bool = false
    var story : PFObject?
    var events : NSArray?
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var storyTitleLabel: UILabel!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var createTextView: UITextView!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var createTitleView: UIView!

    @IBOutlet weak var titleTextField: UITextField!

    @IBOutlet weak var createViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storyTableView: UITableView!
    
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var videoContainer: UIView!
    var createViews = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        storyTableView.delegate = self
        storyTableView.dataSource = self
        var createButton :UIBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: "createEvent")
        self.navigationItem.rightBarButtonItem = createButton
        if newStory == false {
            createViewTopConstraint.constant = -329
            self.createView.hidden = true
            createTitleView.hidden = true
            titleView.hidden = false
        } else {
            createViewTopConstraint.constant = 0
            self.createView.hidden = false
            titleView.hidden = true
            createTitleView.hidden = false
            titleView.hidden = true
        }

//        createViewLeadingConstraint.constant = screenSize.width/4
//        createViewTrailingConstraint.constant = screenSize.width/4

        createViews = [cameraContainer, textContainer, videoContainer]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if events != nil {
            return self.events!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = storyTableView.dequeueReusableCellWithIdentifier("StoryTextTableViewCell") as StoryTextTableViewCell
        var event : PFObject?
        if (events != nil) {
            event = events![indexPath.row] as PFObject
            cell.eventTextLabel.text = event!["text"] as? String
            cell.timestampLabel.text = "\(event!.createdAt)"
        }
        

        return cell

    }
    
    func createEvent() {
        self.view.layoutIfNeeded()
        self.createView.hidden = false
        self.createViewTopConstraint.constant = 0
//        createViewLeadingConstraint.constant = 0
//        createViewTrailingConstraint.constant = 0
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
            })
        
    }

    @IBAction func closeCompose(sender: AnyObject) {
        minimizeCreateView()
    }
    
    func minimizeCreateView() {
        self.view.layoutIfNeeded()
        
        self.createViewTopConstraint.constant = -329
        //        createViewLeadingConstraint.constant = screenSize.width/4
        //        createViewTrailingConstraint.constant = screenSize.width/4
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.createView.hidden = true
        })

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func textSubmitButtonWasTapped(sender: AnyObject) {
        if (story != nil) {
            var event: PFObject = PFObject(className: "Event")
            event["storyObject"] = self.story!
            event["text"] = self.createTextView.text
            event.saveInBackgroundWithBlock({
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    println("Event successfully saved")
                    self.minimizeCreateView()
                    self.createTextView.text = ""
                    self.requestEventsForStory()
                    self.view.endEditing(true)
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the event: \(error.description)")
                }
            })
        } else {
            
            story = PFObject(className: "Story")
            story!["title"] = titleTextField.text
            story!["user"] = PFUser.currentUser().username
            story!.saveInBackgroundWithBlock({
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    var event: PFObject = PFObject(className: "Event")
                    event["storyObject"] = self.story!
                    event["text"] = self.createTextView.text
                    event.saveInBackgroundWithBlock({
                        (success: Bool, error: NSError!) -> Void in
                        if (success) {
                            // The object has been saved.
                            println("Story and event successfully saved")
                            self.storyTitleLabel.text = self.story!["title"] as? String
                            self.userLabel.text = PFUser.currentUser().username
                            self.createTitleView.hidden = true
                            self.titleView.hidden = false
                            self.minimizeCreateView()
                            self.createTextView.text = ""
                            self.requestEventsForStory()
                            self.view.endEditing(true)
                        } else {
                            // There was a problem, check error.description
                            println("There was an error saving the event: \(error.description)")
                        }
                    })
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the story: \(error.description)")
                }
            })
        
        }

    }

    @IBAction func videoSelectorWasTapped(sender: AnyObject) {
        for view in createViews {
            (view as UIView).hidden = true
            videoContainer.hidden = false
        }
    }

    @IBAction func cameraSelectorWasTapped(sender: AnyObject) {
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
    }


    @IBAction func textSelectorWasTapped(sender: AnyObject) {
        println("Text button was tapped")
        for view in createViews {
            (view as UIView).hidden = true
            textContainer.hidden = false
        }
    }
    
    func requestEventsForStory() {
        var query = PFQuery(className:"Event")
        query.whereKey("storyObject", equalTo:self.story)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects.count) events.")
                self.events = objects
                self.storyTableView.reloadData()
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        var text = object["text"]
                        println("Object ID: \(object.objectId), Timestamp: \(object.createdAt?), Text: \(text)")
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
            }
        }
    }

}
