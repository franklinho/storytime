//
//  PostersViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 5/7/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

protocol PostersViewControllerDelegate{
    func posterWasSelected(user : PFUser)
}

class PostersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var posters = []
    
    var delegate : PostersViewControllerDelegate?

    @IBOutlet weak var postersTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.postersTableView.delegate = self
        self.postersTableView.dataSource = self
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = postersTableView.dequeueReusableCellWithIdentifier("UserTableViewCell") as! UserTableViewCell
        var poster : PFUser = posters[indexPath.row] as! PFUser
        cell.user = poster
        cell.populateCellWithUser(poster)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedPoster = posters[indexPath.row] as! PFUser
        self.delegate?.posterWasSelected(selectedPoster)
        self.dismissViewControllerAnimated(true, completion: {})
    }

    
    @IBAction func closeButtonWasTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
