//
//  EULAViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 5/13/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {

    @IBOutlet weak var eulaTextView: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        closeButton.layer.cornerRadius = 22
        closeButton.layer.borderWidth = 2
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
        closeButton.clipsToBounds = true
        eulaTextView.scrollRangeToVisible(NSMakeRange(0,1))
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
