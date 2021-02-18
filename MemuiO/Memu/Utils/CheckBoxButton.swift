//
//  CheckBoxButton.swift
//  Memu
//
//  Created by Tejaswini N on 18/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import UIKit

class CheckBoxButton: UIButton {

    // Images
    let checkedImage = UIImage(named: "TICKBOX")! as UIImage
    let uncheckedImage = UIImage(named: "Tickbox-1")! as UIImage

    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(uncheckedImage, for: .normal)
            } else {
                self.setImage(checkedImage, for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        self.isUserInteractionEnabled = false
//        self.addTarget(self, action: #selector(CheckBoxButton.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        self.isChecked = false
    }

    func buttonClicked(sender: UIButton) {
        if sender == self {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true
            }
        }
    }

}
