//
//  SettingsViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 5/1/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var followNotificationsSwitch: UISwitch!
    @IBOutlet weak var closeButton: UIButton!
    let defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var storyNotificationsSwitch: UISwitch!
    @IBOutlet weak var commentNotificationsSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        closeButton.layer.cornerRadius = 23
        closeButton.layer.borderWidth = 3
        closeButton.layer.borderColor = UIColor.whiteColor().CGColor
        closeButton.clipsToBounds = true
        
        
        
        
        if defaults.boolForKey("storyNotificationsOn") == false {
            storyNotificationsSwitch.on = false
        } else {
            storyNotificationsSwitch.on = true
        }
        
        if defaults.boolForKey("commentNotificationsOn") == false {
            commentNotificationsSwitch.on = false
        } else {
            commentNotificationsSwitch.on = true
        }
        
        if defaults.boolForKey("followNotificationsOn") == false {
            followNotificationsSwitch.on = false
        } else {
            followNotificationsSwitch.on = true
        }
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

    @IBAction func storyNotificationsSwitchWasTapped(sender: AnyObject) {
        if storyNotificationsSwitch.on == true {
            defaults.setBool(true, forKey: "storyNotificationsOn")
            let installation = PFInstallation.currentInstallation()
            installation["storyNotificationsOn"] = true
            installation.saveInBackground()
        } else {
            defaults.setBool(false, forKey: "storyNotificationsOn")
            let installation = PFInstallation.currentInstallation()
            installation["storyNotificationsOn"] = false
            installation.saveInBackground()
        }
        
    }

    @IBAction func followNotificationsSwitchWasTapped(sender: AnyObject) {
        if followNotificationsSwitch.on == true {
            defaults.setBool(true, forKey: "followNotificationsOn")
            let installation = PFInstallation.currentInstallation()
            installation["followNotificationsOn"] = true
            installation.saveInBackground()
        } else {
            defaults.setBool(false, forKey: "followNotificationsOn")
            let installation = PFInstallation.currentInstallation()
            installation["followNotificationsOn"] = false
            installation.saveInBackground()
        }

    }
    @IBAction func commentNotificationsSwitchWasTapped(sender: AnyObject) {
        if commentNotificationsSwitch.on == true {
            defaults.setBool(true, forKey: "commentNotificationsOn")
            let installation = PFInstallation.currentInstallation()
            installation["commentNotificationsOn"] = true
            installation.saveInBackground()
        } else {
            defaults.setBool(false, forKey: "commentNotificationsOn")
            let installation = PFInstallation.currentInstallation()
            installation["commentNotificationsOn"] = false
            installation.saveInBackground()
        }
    }
    @IBAction func closeButtonWasTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
