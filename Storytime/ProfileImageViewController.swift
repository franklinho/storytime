//
//  ProfileImageViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 5/7/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class ProfileImageViewController: UIViewController {
    var profileImage : UIImage?
    @IBOutlet weak var profileImageView: UIImageView!

    let screenSize: CGRect = UIScreen.mainScreen().bounds

    @IBOutlet weak var profileImageViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImageViewHeightConstraint.constant = self.screenSize.width
        self.view.layoutIfNeeded()
        
        self.profileImageView.image = self.profileImage
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

    @IBAction func closeButtonWasTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
