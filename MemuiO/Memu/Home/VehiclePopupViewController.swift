//
//  VehiclePopupViewController.swift
//  Memu
//
//  Created by Tejaswini N on 22/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import DropDown

class VehiclePopupViewController: UIViewController {
    @IBOutlet weak var rs_per_km: UITextField!
    
    @IBOutlet weak var btnVehicleList: UIButton!
    @IBOutlet weak var vehicle_brand: UITextField!
    @IBOutlet weak var vehicle_name: UITextField!
    let chooseDropDown = DropDown()
    var vehicleArray:[String] = []
    var parentVC : BookingViewController?
    var vehicle_id = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomBorder(myTextField: vehicle_name)
        addBottomBorder(myTextField: vehicle_brand)
        getVehicleList()
    }
   
    @IBAction func close(_ sender: Any) {
        if(self.vehicle_id != "" && rs_per_km.text == "") {
           self.showAlert("", "Please enter the rate per kilometer")
        } else {
           
            removeAnimate()
        }
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
               
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                 self.parentVC?.setVehicleID(vehicle_id: self.vehicle_id, rs_per_km: self.rs_per_km.text ?? "")
                 NotificationCenter.default.post(name: Notification.Name("vehicleDeatils"), object: nil, userInfo:nil)
            }
        })
    }
    @IBAction func vehicle_list(_ sender: Any) {
         chooseDropDown.show()
    }
    func addBottomBorder(myTextField : UITextField) {
       let bottomLine = CALayer()
       bottomLine.frame = CGRect(x: 0.0, y: myTextField.frame.height - 1, width: myTextField.frame.width, height: 1.0)
       bottomLine.backgroundColor = UIColor.purple.cgColor
       myTextField.borderStyle = UITextField.BorderStyle.none
       myTextField.layer.addSublayer(bottomLine)
    }
    func getVehicleList() {
        RestDataSource.getVehicleList()
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success"  {
                self?.setupChooseDropDown(value: value)
            } else {
                self?.showAlert(value.status, value.message)
            }
        }).disposed(by: rx.bag)
    }
    func setupChooseDropDown(value : VehicleListResponse) {
        chooseDropDown.anchorView = btnVehicleList
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseDropDown.bottomOffset = CGPoint(x: 0, y: btnVehicleList.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        for feed in value.vehicle_list {
            vehicleArray.append(feed.vehicle_name)
        }
        if(value.vehicle_list.count != 0) {
            self.btnVehicleList.setTitle(vehicleArray[0], for: .normal)
            self.vehicle_name.text = value.vehicle_list[0].vehicle_name
            self.vehicle_brand.text = value.vehicle_list[0].vehicle_brand
            self.vehicle_id = value.vehicle_list[0].vehicle_id
        }
        chooseDropDown.dataSource = vehicleArray
        // Action triggered on selection
        chooseDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnVehicleList.setTitle("\(item)", for: .normal)
            self?.vehicle_name.text = value.vehicle_list[index].vehicle_name
            self?.vehicle_brand.text = value.vehicle_list[index].vehicle_brand
            self?.vehicle_id = value.vehicle_list[index].vehicle_id

        }
    }
}
