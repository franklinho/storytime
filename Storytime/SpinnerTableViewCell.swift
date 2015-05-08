//
//  SpinnerTableViewCell.swift
//  Storytime
//
//  Created by Franklin Ho on 5/8/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class SpinnerTableViewCell: UITableViewCell {

    @IBOutlet weak var spinnerActivityIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
        spinnerActivityIndicator.startAnimating()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
