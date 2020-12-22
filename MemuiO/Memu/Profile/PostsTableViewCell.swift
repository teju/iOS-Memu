//
//  PostsTableViewCell.swift
//  Memu
//
//  Created by Tejaswini N on 16/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import Mapbox
class PostsTableViewCell: UITableViewCell {

    @IBOutlet weak var map_view: MGLMapView!
    @IBOutlet weak var post_img: UIImageView!
    @IBOutlet weak var description_txt: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    @IBOutlet weak var image_view: UIImageView!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
