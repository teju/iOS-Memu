//
//  VehicleTableViewCell.swift
//  Memu
//
//  Created by Tejaswini N on 11/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class VehicleTableViewCell: UICollectionViewCell {
 @IBOutlet weak var reg_no: UITextField!
  @IBOutlet weak var type: UITextField!
    @IBOutlet weak var yellowboard: CheckBoxButton!
    @IBOutlet weak var brand: UITextField!
    @IBOutlet weak var whiteboard: CheckBoxButton!
    @IBOutlet weak var model: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
           super.layoutSubviews()

           contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
       }

}
