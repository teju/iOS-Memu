//
//  FriendsTableViewCell.swift
//  Memu
//
//  Created by Tejaswini N on 16/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var btnAcceptRemove: UIButton!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
