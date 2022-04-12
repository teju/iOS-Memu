//
//  ReurringViewController.swift
//  Memu
//
//  Created by Tejaswini N on 23/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class ReurringViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var to_address: UILabel!
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var from_address: UILabel!
    @IBOutlet weak var weekDayscollection: UICollectionView!
    let weekDays = ["Mo","Tu","We","Th","Fr","Sa","Su"]
    var daysarray:[String] = []
    var complted_list: ScheduledList?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("complted_list \(complted_list?.matched_budies.count)")
        from_address.text = complted_list?.fromaddress.formattedAddress
        to_address.text = complted_list?.toaddress.formattedAddress
        time.text = complted_list?.time
        
        daysarray = complted_list?.days.components(separatedBy: ",") as! [String]
        print("daysarray \(daysarray)")

    }
    
    @IBAction func close(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("GOBACK"), object: nil, userInfo:nil)

        self.removeAnimate()
    }
    @IBAction func pause(_ sender: Any) {
        editRecurring(status: getStatus())
    }
    
    @IBAction func btndelete(_ sender: Any) {
        editRecurring(status: "deleted")
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 7
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "week_days", for: indexPath as IndexPath) as! WeekDaysCollectionViewCell
           cell.week_day_txt.text = weekDays[indexPath.row]
            if(daysarray.contains(weekDays[indexPath.row])) {
                cell.backgroundColor = UIColor.green
            }
           return cell
       }
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let cell = collectionView.cellForItem(at: indexPath)
           if(!daysarray.contains(weekDays[indexPath.row])) {
               cell?.backgroundColor = UIColor.green
               daysarray.append(weekDays[indexPath.row])
           } else {
               cell?.backgroundColor = .clear
               daysarray.remove(at: indexPath.row)
           }
           print("daysarray \(daysarray)")
       }
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

           let totalCellWidth = 40 * 7
           let totalSpacingWidth = 0

           let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2

           return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right:leftInset)

       }

    func editRecurring(status : String) {
        var is_recurring_ride = "yes"
        if(daysarray.count == 0) {
            is_recurring_ride = "yes"
        }
        let from = Address()
        from.address = complted_list!.fromaddress.address
        from.lattitude = complted_list!.fromaddress.lattitude
        from.type = complted_list!.fromaddress.type
        from.pincode = complted_list!.fromaddress.pincode
        from.country = complted_list!.fromaddress.country
        from.state = complted_list!.fromaddress.state
        from.location = complted_list!.fromaddress.location
        from.city = complted_list!.fromaddress.city
        from.formattedAddress = complted_list!.fromaddress.formattedAddress

        let to = Address()
        to.address = complted_list!.toaddress.address
        to.lattitude = complted_list!.toaddress.lattitude
        to.type = complted_list!.toaddress.type
        to.pincode = complted_list!.toaddress.pincode
        to.country = complted_list!.toaddress.country
        to.state = complted_list!.toaddress.state
        to.location = complted_list!.toaddress.location
        to.city = complted_list!.toaddress.city
        to.formattedAddress = complted_list!.toaddress.formattedAddress

        print("toRestDataSource \(to)")
        
        RestDataSource.postEditRecuring(id: complted_list?.id ?? "", date: complted_list?.date ?? "", type: complted_list?.type ?? "", no_of_seats: complted_list?.no_of_seats ?? "", vehicle_id: complted_list?.vehicle_id ?? "", status: status, is_recurring_ride: is_recurring_ride, days: daysarray.joined(separator:","), from: from, to: to, time: complted_list!.time)
           .showLoading(on: self.view)
           .subscribe(onNext: { [weak self] value in
               if value.status == "success"  {
                NotificationCenter.default.post(name: Notification.Name("GOBACK"), object: nil, userInfo:nil)

                self?.removeAnimate()
               } else {
                   self?.showAlert(value.status, value.message)
               }
           }).disposed(by: rx.bag)
       }
    func getStatus() -> String{
        if(complted_list?.type == "offer_ride") {
            if(complted_list?.status == "scheduled") {
                return "Pause"
            } else {
                return "Scheduled"
            }
        }
        else if(complted_list?.type == "find_ride") {
            if(complted_list?.status == "requested") {
                return "Pause"
            } else {
                return "Requested"
            }
        } else {
            return complted_list?.status ?? "pause"
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
                   
               }
           })
       }
}
