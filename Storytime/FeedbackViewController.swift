//
//  FeedbackViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 7/9/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var hamburgerVC : HamburgerViewController?
    var userSentiment = "happy"
    let happyTitle = "We'd love to know how we can make Storyweave better. If you like the app, please leave a review on the app store!"
    let confusedTitle = "If you're confused about how to use Storyweave, feel free to contact the Storyweave team! We'd be happy to help."
    let unhappyTitle = "We'd love to know how we can make Storyweave better. Please reach out to the Storyweave team. We'd love your feedback."

    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var feedbackTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        hamburgerVC = self.parentViewController!.parentViewController as? HamburgerViewController
        // Do any additional setup after loading the view.
        feedbackTableView.delegate = self
        feedbackTableView.dataSource = self
        
        if (feedbackTableView.respondsToSelector(Selector("separatorInset"))) {
            self.feedbackTableView.separatorInset = UIEdgeInsetsZero;
        }
        
        if (feedbackTableView.respondsToSelector(Selector("layoutMargins"))) {
            self.feedbackTableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        feedbackTableView.tableFooterView = UIView(frame: CGRectZero)

        feedbackTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        feedbackTableView.reloadData()
        
        if userSentiment == "happy" {
            feedbackLabel.text =  happyTitle
        } else  if userSentiment == "confused" {
            feedbackLabel.text =  confusedTitle
        } else {
            feedbackLabel.text =  unhappyTitle
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = feedbackTableView.dequeueReusableCellWithIdentifier("FeedbackTableViewCell") as! FeedbackTableViewCell
        if (cell.respondsToSelector(Selector("layoutMargins"))) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
        if userSentiment == "happy" {
            if indexPath.row == 0 {
                cell.feedbackIconImage.image = UIImage(named: "feedbackStarIcon")
                cell.feedbackTitle.text = "Write a Review"
                cell.action = "review"
            } else {
                cell.feedbackIconImage.image = UIImage(named: "feedbackEmailIcon")
                cell.feedbackTitle.text = "Contact the Storyweave team"
                cell.action = "email"
            }
        } else {
            cell.feedbackIconImage.image = UIImage(named: "feedbackEmailIcon")
            cell.feedbackTitle.text = "Contact the Storyweave team"
            cell.action = "email"
        }
        
        
        
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userSentiment != "happy" {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = feedbackTableView.cellForRowAtIndexPath(indexPath) as! FeedbackTableViewCell
        if cell.action == "review" {
            let reviewLink = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=986187127"
            
            UIApplication.sharedApplication().openURL(NSURL(string: reviewLink)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "mailto://info@getstoryweave.com")!)
        }
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if userSentiment == "happy" {
//            return happyTitle
//        } else  if userSentiment == "confused" {
//            return confusedTitle
//        } else {
//            return unhappyTitle
//        }
//    }
    
    @IBAction func menuButtonWasTapped(sender: AnyObject) {
        
        
        if hamburgerVC!.hamburgerShowing == true {
            hamburgerVC!.hideHamburgerMenu()
        } else {
            hamburgerVC!.showHamburgerMenu()
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
