
//
//  SignupView.swift
//  Storytime
//
//  Created by Franklin Ho on 5/13/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

protocol SignupViewDelegate{
    func privacyPolicyWasTapped()
    func EULAWasTapped()
}

class SignupView: UIView {
    
    @IBOutlet weak var signupLabel: UILabel!
//    UIFont *arialFont = [UIFont fontWithName:@"arial" size:18.0];
//    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: arialFont forKey:NSFontAttributeName];
//    NSMutableAttributedString *aAttrString = [[NSMutableAttributedString alloc] initWithString:title attributes: arialDict];
//    
//    UIFont *VerdanaFont = [UIFont fontWithName:@"verdana" size:12.0];
//    NSDictionary *verdanaDict = [NSDictionary dictionaryWithObject:VerdanaFont forKey:NSFontAttributeName];
//    NSMutableAttributedString *vAttrString = [[NSMutableAttributedString alloc]initWithString: newsDate attributes:verdanaDict];
//    [vAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:(NSMakeRange(0, 15))];
//    
//    [aAttrString appendAttributedString:vAttrString];
//    
//    
//    lblText.attributedText = aAttrString;
    
    
    
    
    var delegate : SignupViewDelegate?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override func drawRect(rect: CGRect) {
        var start : NSMutableAttributedString = NSMutableAttributedString(string: "By signing up you agree to our ")
        var privacy : NSMutableAttributedString = NSMutableAttributedString(string: "Privacy Policy ")
        var and : NSMutableAttributedString = NSMutableAttributedString(string: "and ")
        var eula : NSMutableAttributedString = NSMutableAttributedString(string: "EULA.")
        
        start.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, start.length))
        and.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, and.length))
        
        privacy.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: NSMakeRange(0, privacy.length))
        eula.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: NSMakeRange(0, eula.length))
        
        start.appendAttributedString(privacy)
        start.appendAttributedString(and)
        start.appendAttributedString(eula)
        
        self.signupLabel.attributedText! = start
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 175, 36)
    }
    
    @IBAction func privacyPolicyButtonWasTapped(sender: AnyObject) {
        self.delegate?.privacyPolicyWasTapped()
    }

    @IBAction func EULAButtonWasTapped(sender: AnyObject) {
        self.delegate?.EULAWasTapped()
    }
}
