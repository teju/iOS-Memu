//
//  HistoryViewController.swift
//  Memu
//
//  Created by Tejaswini N on 22/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftLocation
class HistoryViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var no_rides: UILabel!
    
    @IBOutlet weak var btnCompletedRides: UIButton!
    @IBOutlet weak var btnscheduledRides: UIButton!
    @IBOutlet weak var table_title: UILabel!
    
    @IBOutlet weak var no_recurring_list: UILabel!
    @IBOutlet weak var profile_picture: roundImageView!
    @IBOutlet weak var recurring_cell: UICollectionView!
    @IBOutlet weak var history_cell: UITableView!
    
    var scheduled_list = [ScheduledList]()
    var complted_list = [ScheduledList]()
    var matched_budies = [MatchedBuddies]()
    var isCompletedRides = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageURL = URL(string: UserDefaults.profile_picture!)!
        profile_picture.sd_setImage(with: imageURL)
        history_cell.estimatedRowHeight = 220
        history_cell.rowHeight = UITableView.automaticDimension
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        history_cell.beginUpdates()
        history_cell.endUpdates()
         getHistoryList(url: "booking/my-rides")
         getRecurringList()
    }
    
    @IBAction func back(_ sender: Any) {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
    @IBAction func completedRides(_ sender: Any) {
        btnCompletedRides.setUnderLine(colour: UIColor.black)
        btnscheduledRides.removeUnderline()
        table_title.text = "Completed Rides"
        getHistoryList(url: "booking/my-completed-rides")

    }
    @IBAction func scheduledRides(_ sender: Any) {
        btnCompletedRides.removeUnderline()
        btnscheduledRides.setUnderLine(colour: UIColor.black)
        table_title.text = "Upcoming Rides"
        getHistoryList(url: "booking/my-rides")
    }
    
    @IBAction func new_ride(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func getHistoryList(url : String) {
        RestDataSource.getHistoryList(url: url)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success" {
                self?.no_rides.isHidden = true
                var scrollheight = 260
                if(value.scheduled_list.count != 0) {
                    self?.isCompletedRides = false
                    self?.scheduled_list = value.scheduled_list
                } else {
                    scrollheight = 280
                    self?.isCompletedRides = true
                    self?.scheduled_list = value.completed_list
                }

                
                DispatchQueue.main.async() {

                    self?.history_cell.frame.size.height = CGFloat(scrollheight * (self?.scheduled_list.count)!) + CGFloat(10 * (self?.scheduled_list.count)!)
                    self?.history_cell.reloadData()
                    self?.history_cell.layoutIfNeeded()
                    self?.history_cell.setNeedsFocusUpdate();
                    self?.scrollView.contentSize = CGSize(width:
                        UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+CGFloat((self?.scheduled_list.count)! * scrollheight) - 180)
                }
            } else {
                self?.scheduled_list.removeAll()
                self?.no_rides.isHidden = false
                self?.no_rides.text = value.message
                DispatchQueue.main.async() {
                     self?.history_cell.reloadData()
                }
            }
        }).disposed(by: rx.bag)
    }
    func getRecurringList() {
        RestDataSource.getRecurryingList()
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success" {
                self?.no_recurring_list.isHidden = true
                self?.complted_list = value.scheduled_list
                self?.recurring_cell.reloadData()
            } else {
                self?.no_recurring_list.isHidden = false
                self?.no_recurring_list.text = value.message
                self?.complted_list.removeAll()
                self?.recurring_cell.reloadData()
               // self?.showAlert(value.status, value.message)
            }
        }).disposed(by: rx.bag)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = history_cell.dequeueReusableCell(withIdentifier: "history_cell", for: indexPath as IndexPath) as! HistoryTableViewCell
        cell.fromAddress.text = scheduled_list[indexPath.section].fromaddress.formattedAddress
        cell.toAddress.text = scheduled_list[indexPath.section].toaddress.formattedAddress
        let date = getDate(date: scheduled_list[indexPath.section].date)
        let time = scheduled_list[indexPath.section].time
        cell.dateTime.text = "\(date) \(time)"
        matched_budies = scheduled_list[indexPath.section].matched_budies
        if(isCompletedRides) {
            cell.coins.isHidden = false
            let coins_spent = scheduled_list[indexPath.section].coins_spent.amount + scheduled_list[indexPath.section].coins_spent.memu_amount
            cell.money_spent.text = "Money Earned: \(coins_spent)"
            cell.money_earned.text = "Money Earned: \(scheduled_list[indexPath.section].coins_earned)"
        } else {
            cell.coins.isHidden = true
        }
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)

       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView.tag == 0) {
            let cell = recurring_cell.dequeueReusableCell(withReuseIdentifier: "recurring_cell", for: indexPath as IndexPath) as! RecurringCollectionViewCell
            cell.from_address.text = complted_list[indexPath.row].fromaddress.formattedAddress
            cell.to_address.text = complted_list[indexPath.row].toaddress.formattedAddress
            cell.time.text = complted_list[indexPath.row].time
            cell.daystxt.text = complted_list[indexPath.row].days
            cell.btnEdit.addTarget(self, action: #selector(editRecurring), for: .touchUpInside)
            return cell
        } else {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "matching_buddies", for: indexPath as IndexPath) as! MatchingBuddiesCollectionViewCell
            cell.profile_img.makeRounded()
            if(matched_budies[indexPath.row].photo.profile_path != "") {
                let imageURL = URL(string: matched_budies[indexPath.row].photo.profile_path)!
                cell.profile_img.sd_setImage(with: imageURL)
            }
            cell.name.text = matched_budies[indexPath.row].name
            return cell
        }
    }
    @objc func editRecurring(_ sender: UIButton) {
        
        let currentloc = CLLocationCoordinate2D(latitude: (self.complted_list[sender.tag].fromaddress.lattitude as NSString).doubleValue, longitude:(complted_list[sender.tag].fromaddress.longitude as NSString).doubleValue)
        let destinationloc = CLLocationCoordinate2D(latitude: (self.complted_list[sender.tag].toaddress.lattitude as NSString).doubleValue, longitude:(complted_list[sender.tag].toaddress.longitude as NSString).doubleValue)
        let storyboard = UIStoryboard(name: "NavigationController", bundle: nil)
                          let mainVC = storyboard.instantiateViewController(withIdentifier: "AdvancedViewController") as! AdvancedViewController
                       mainVC.currentLoc = currentloc
                       mainVC.destinationLoc = destinationloc
                        mainVC.isFromRecurring = true
                    mainVC.complted_list = self.complted_list[sender.tag]
                   self.navigationController?.pushViewController(mainVC, animated: true)
    }
    func getDate(date : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from:date)!
        dateFormatter.dateFormat = "EEE,MMM dd yyyy"

        let myStringafd = dateFormatter.string(from: date)
        return myStringafd
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 0) {
            return complted_list.count
        } else {
            return matched_budies.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return scheduled_list.count
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isCompletedRides {
            return 280
        }
        return 260
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "NavigationController", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "AdvancedViewController") as! AdvancedViewController
        mainVC.currentLoc = CLLocationCoordinate2D(latitude: (scheduled_list[indexPath.row].fromaddress.lattitude as NSString).doubleValue, longitude: (scheduled_list[indexPath.row].fromaddress.longitude as NSString).doubleValue)
        mainVC.destinationLoc = CLLocationCoordinate2D(latitude: (scheduled_list[indexPath.row].toaddress.lattitude as NSString).doubleValue, longitude: (scheduled_list[indexPath.row].toaddress.longitude as NSString).doubleValue)
        mainVC.isFromHome = true
        mainVC.trip_or_rider_id = scheduled_list[indexPath.row].id
        mainVC.type = scheduled_list[indexPath.row].type
        mainVC.status = scheduled_list[indexPath.row].status
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if(collectionView.tag == 0) {

                  let collectionViewWidth = self.recurring_cell.bounds.width
                  return CGSize(width: collectionViewWidth - 50, height: 184)
            } else {
                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
                
                let numberofItem: CGFloat = 2
                
                let collectionViewWidth = collectionView.bounds.width
                
                let extraSpace = (numberofItem - 1) * flowLayout.minimumInteritemSpacing
                
                let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left
                
                let width = Int((collectionViewWidth - extraSpace - inset) / numberofItem)
                            
                return CGSize(width: width, height: width + 10)
            }
      }
}
extension UIImageView {

    func makeRounded() {

        self.layer.borderWidth = 0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
