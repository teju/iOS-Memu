//
//  ReferralAddViewController.swift
//  Memu
//
//  Created by Tejaswini N on 09/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class ReferralAddViewController: UITableViewController {
    @IBOutlet weak var friends: UITableView!
    
    @IBOutlet weak var cityTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //friends.delegate = self
        //friends.dataSource = self
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cityTableView || tableView == friends {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       if tableView == cityTableView || tableView == friends{
            return 60
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == cityTableView {

            let cell = cityTableView.dequeueReusableCell(withIdentifier: "city_cell",
            for: indexPath as IndexPath) as! CityTableViewCell
            return cell
        } else if tableView == friends {

            let cell = friends.dequeueReusableCell(withIdentifier: "friends_cell",
            for: indexPath as IndexPath) as! CityTableViewCell
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    

}
