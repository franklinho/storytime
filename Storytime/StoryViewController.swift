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

    @IBOutlet weak var createView: UIView!

    @IBOutlet weak var createViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storyTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        storyTableView.delegate = self
        storyTableView.dataSource = self
        var createButton :UIBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: "createEvent")
        self.navigationItem.rightBarButtonItem = createButton
        createViewTopConstraint.constant = -329
//        createViewLeadingConstraint.constant = screenSize.width/4
//        createViewTrailingConstraint.constant = screenSize.width/4
        self.createView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = storyTableView.dequeueReusableCellWithIdentifier("StoryImageTableViewCell") as StoryImageTableViewCell
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


}
