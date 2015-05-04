//
//  RankingSwitch.swift
//  Storytime
//
//  Created by Franklin Ho on 5/4/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

protocol RankingSwitchDelegate{
    func rankingSwitchWasTapped()
}

class RankingSwitch: UIView {
    var hot = true
    @IBOutlet weak var switchLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var hotLabel: UILabel!
    @IBOutlet weak var recentLabel: UILabel!
    @IBOutlet weak var thumbView: UIView!
    var delegate : RankingSwitchDelegate?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func drawRect(rect: CGRect) {
        self.layer.cornerRadius = 18
        self.clipsToBounds = true
        self.thumbView.layer.cornerRadius = 16
        self.thumbView.clipsToBounds = true
    }

    @IBAction func didTapRankingSwitch(sender: AnyObject) {
        self.delegate?.rankingSwitchWasTapped()
        if hot == true {
            self.switchLeadingConstraint.constant = 102
            UIView.animateWithDuration(0.3, animations: {
                self.layoutIfNeeded()
                
                }, completion: {
                    (value: Bool) in
                    self.hotLabel.hidden = true
                    self.recentLabel.hidden = false
                    self.hot = false
            })
        } else {
            self.switchLeadingConstraint.constant = 2
            UIView.animateWithDuration(0.2, animations: {
                self.layoutIfNeeded()
                
                }, completion: {
                    (value: Bool) in
                    self.recentLabel.hidden = true
                    self.hotLabel.hidden = false
                    self.hot = true
            })
        }
    }
}
