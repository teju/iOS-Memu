//
//  HistoryTableViewCell.swift
//  Memu
//
//  Created by Tejaswini N on 22/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var money_earned: UILabel!
    @IBOutlet weak var money_spent: UILabel!

    @IBOutlet weak var coins: UIView!
    @IBOutlet weak var matching_buddies: UICollectionView!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var toAddress: UILabel!
    @IBOutlet weak var fromAddress: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        matching_buddies.delegate = dataSourceDelegate
        matching_buddies.dataSource = dataSourceDelegate
        matching_buddies.reloadData()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
    }
}
