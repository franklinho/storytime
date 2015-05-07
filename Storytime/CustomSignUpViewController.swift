//
//  CustomSignUpViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/10/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class CustomSignUpViewController: PFSignUpViewController {
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.signUpView!.logo!.hidden = true
        self.signUpView!.backgroundColor = UIColor(red: 41.0/255.0, green: 37.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        var storyWeaveLogo = UIImageView(image: UIImage(named: "AlternativeStoryweaveLogoTransparent.png"))
        storyWeaveLogo.frame = CGRectMake((screenSize.width - 300) / 2, 150, 300, 300)
        self.view.addSubview(storyWeaveLogo)
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
