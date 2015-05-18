//
//  CustomSignUpViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/10/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class CustomSignUpViewController: PFSignUpViewController, SignupViewDelegate {
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.signUpView!.logo!.hidden = true
        self.signUpView!.backgroundColor = UIColor(red: 41.0/255.0, green: 37.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        var storyWeaveLogo = UIImageView(image: UIImage(named: "AlternativeStoryweaveLogoTransparent.png"))
        storyWeaveLogo.frame = CGRectMake((screenSize.width - 300) / 2, (screenSize.height - 300)/2-60, 300, 300)
        self.view.addSubview(storyWeaveLogo)
        var storyWeaveLabel = UILabel(frame: CGRectMake((screenSize.width - 162)/2, (screenSize.height - 300)/2+200, 162, 41))
        storyWeaveLabel.text = "Storyweave"
        storyWeaveLabel.font = UIFont(name: "OpenSans", size: 30)
        storyWeaveLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(storyWeaveLabel)
        
        var policyView = NSBundle.mainBundle().loadNibNamed("SignUpView", owner: self, options: nil)[0] as! SignupView
        policyView.backgroundColor = UIColor.clearColor()
        policyView.frame = CGRectMake((self.screenSize.width - 175)/2, (self.screenSize.height - 300)/2+271, 175, 36)
        policyView.delegate = self
        self.view.addSubview(policyView)
    }
    
    func privacyPolicyWasTapped() {
        var privacyVC : PrivacyPolicyViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PrivacyPolicyViewController") as! PrivacyPolicyViewController
        self.presentViewController(privacyVC, animated: true, completion: nil)
    }
    
    func EULAWasTapped() {
        var eulaVC : EULAViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EULAViewController") as! EULAViewController
        self.presentViewController(eulaVC, animated: true, completion: nil)
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

}
