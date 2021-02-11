//
//  SettingsViewController.swift
//  Memu
//
//  Created by Tejaswini N on 11/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var vehicletable: UITableView!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var drivinfLL: UITextField!
    @IBOutlet weak var officeAddress: UITextField!
    @IBOutlet weak var homeAddress: UITextField!
    @IBOutlet weak var workEmail: UITextField!
    @IBOutlet weak var personalEmail: UITextField!
    @IBOutlet weak var mobile_number: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var name: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        drivinfLL.setUnderLine()
        officeAddress.setUnderLine()
        homeAddress.setUnderLine()
        workEmail.setUnderLine()
        personalEmail.setUnderLine()
        mobile_number.setUnderLine()
        name.setUnderLine()
        lastname.setUnderLine()
        getProfileData()

    }
    func initData(param : UserProfile) {
        self.drivinfLL.text = param.personal_details.dl_number
        self.officeAddress.text = param.address.office.formattedAddress
        self.homeAddress.text = param.address.home.formattedAddress
        self.workEmail.text = param.personal_details.office_email
        self.personalEmail.text = param.personal_details.email
        self.mobile_number.text = param.personal_details.mobile
        self.name.text = param.personal_details.firstName
        self.lastname.text = param.personal_details.lastName
    }
    func getProfileData() {
        RestDataSource.postgetProfile(user_id: UserDefaults.user_id!)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.initData(param : value)
            }).disposed(by: rx.bag)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == vehicletable) {
            return 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)

    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == vehicletable) {
            let cell = self.vehicletable.dequeueReusableCell(withIdentifier: "vehicle",
                       for: indexPath as IndexPath) as! VehicleTableViewCell
            cell.reg_no.setUnderLine()
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)

    }
}
