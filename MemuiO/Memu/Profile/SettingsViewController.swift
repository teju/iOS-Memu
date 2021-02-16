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
    @IBOutlet weak var name: UITextField!
    var userProfile :UserProfile!
    var vehicle = [Vehicle]()
    var address = [Address]()

    var VehicleCount = 0
    var btn = UIButton(type: .custom)

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
        floatingButton()
    }
    func prepareParams() {
       let userDic: [String: Any] = [
        "mobile": mobile_number.text ?? "",
        "first_name": name.text ?? "",
        "last_name": lastname.text ?? "",
        "office_email": workEmail.text ?? "",
        "dl_number": drivinfLL.text ?? "",
        "gender": "male",
         "email": personalEmail.text ?? ""]
        
        address.append(userProfile.address.home)
        if(!userProfile.address.office.formattedAddress.isEmpty) {
            address.append(userProfile.address.office)
        }
        
        for var i in 0..<vehicle.count {
            let index = IndexPath(row: 0, section: 0)
            let cell: VehicleTableViewCell = self.vehicletable.cellForRow(at: index) as! VehicleTableViewCell
            let vehicleM =  Vehicle()
            vehicleM.vehicleNo = cell.reg_no.text ?? ""
            vehicleM.vehicleName = cell.model.text ?? ""
            vehicleM.vehicleModelType = cell.type.text ?? ""
            vehicleM.vehicleBrand = cell.brand.text ?? ""
            vehicleM.vehicleType = 2

            vehicle[i] = vehicleM
        }

       
        let dict: [String: Any] = ["user_id":UserDefaults.user_id,"userInfo": userDic,"Vehicle":vehicle.map{ $0.toParams() },"Address":address.map{ $0.toParams() }]
        print("userDic \(dict)")
        saveProfileData(userDic: dict)
    }
    func floatingButton(){
        btn.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: UIScreen.main.bounds.height - 70, width: 100, height: 45)
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setBackgroundImage(UIImage(named: "btn_add_friend"), for: .normal)
        btn.addTarget(self,action: #selector(save(_:)), for: .touchUpInside)
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(btn)
        }
    }
    
    @objc func save(_ sender: Any) {
        
        prepareParams()
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        btn.removeFromSuperview()
    }
    func initData() {
        self.drivinfLL.text = userProfile.personal_details.dl_number
        self.officeAddress.text = userProfile.address.office.formattedAddress
        self.homeAddress.text = userProfile.address.home.formattedAddress
        self.workEmail.text = userProfile.personal_details.office_email
        self.personalEmail.text = userProfile.personal_details.email
        self.mobile_number.text = userProfile.personal_details.mobile
        self.name.text = userProfile.personal_details.firstName
        self.lastname.text = userProfile.personal_details.lastName
    }
    
    func getProfileData() {
        RestDataSource.postgetProfile(user_id: UserDefaults.user_id!)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.userProfile = value
                self?.initData()
                self?.vehicle = self?.userProfile?.vehicle as! [Vehicle]
                if(self?.vehicle.count == 0) {
                    self?.vehicle.append(Vehicle())
                }
                self?.VehicleCount = self?.vehicle.count as! Int
                self?.vehicletable.contentSize.height = CGFloat(300 * self!.VehicleCount)
                self?.vehicletable.backgroundColor = UIColor.red
                self?.tableView.reloadData()
                self?.vehicletable.reloadData()
            }).disposed(by: rx.bag)
    }
   
    func saveProfileData(userDic : [String : Any]) {
        RestDataSource.postsaveProfile(userInfo: userDic)
               .showLoading(on: self.view)
               .subscribe(onNext: { [weak self] value in
                if(value.status == "success") {
                    self?.navigationController?.popViewController(animated: true)
                }
                
               }).disposed(by: rx.bag)
       }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == vehicletable) {
            return VehicleCount
        }
        return super.tableView(tableView, numberOfRowsInSection: section)

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == vehicletable) {
            let cell = self.vehicletable.dequeueReusableCell(withIdentifier: "vehicle",
                       for: indexPath as IndexPath) as! VehicleTableViewCell
            cell.reg_no.setUnderLine()
            cell.type.setUnderLine()
            cell.brand.setUnderLine()
            cell.model.setUnderLine()
            if(indexPath.row <= vehicle.count - 1) {
                let vehicle_details = vehicle[indexPath.row]
                cell.reg_no.text = vehicle[indexPath.row].registrationNo
                cell.type.text = vehicle[indexPath.row].vehicleModelType
                cell.brand.text = vehicle[indexPath.row].vehicleBrand
                cell.model.text = vehicle[indexPath.row].vehicleName
                if( vehicle[indexPath.row].vehicleType == 2) {
                    cell.whiteboard.setImage(UIImage(named: "TICKBOX"), for: .normal)
                    cell.yellowboard.setImage(UIImage(named: "Tickbox-1"), for: .normal)
                } else {
                    cell.whiteboard.setImage(UIImage(named: "TICKBOX"), for: .normal)
                    cell.yellowboard.setImage(UIImage(named: "Tickbox-1"), for: .normal)
                }
            }
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == vehicletable) {
            return 300
        }
        else if(indexPath.row == 2) {
            return CGFloat(300 * VehicleCount)
        }
        return super.tableView(tableView, heightForRowAt: indexPath)

           
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 3) {
            vehicle.append(Vehicle())
            VehicleCount = self.vehicle.count as! Int
            self.vehicletable.frame = CGRect(x: vehicletable.frame.origin.x, y: vehicletable.frame.origin.y, width: vehicletable.frame.size.width, height: CGFloat(300 * VehicleCount))
            self.tableView.reloadData()
            self.vehicletable.reloadData()
            
        }
    }
}
extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
