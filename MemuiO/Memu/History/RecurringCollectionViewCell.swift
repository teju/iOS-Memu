//
//  RecurringCollectionViewCell.swift
//  Memu
//
//  Created by Tejaswini N on 22/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class RecurringCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var from_address: UILabel!
    @IBOutlet weak var to_address: UILabel!
    
    @IBOutlet weak var daystxt: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var time: UILabel!
}
