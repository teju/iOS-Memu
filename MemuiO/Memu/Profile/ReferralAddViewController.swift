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
    
    @IBOutlet weak var lblalerts: UILabel!
    @IBOutlet weak var lblMakeMoney: UILabel!
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var ratings: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    var city_earners = [City]()
    var friend_earners = [City]()
    @IBOutlet weak var lbllevel: UILabel!
    @IBOutlet weak var coins_earned: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        lblMakeMoneyText()
        getUserData()
        getWalletBalanceData()
        getTopEarnersData()
        lblalerts.text = "Create real-time road\nalerts for other “memu” Users & start earning reputation coins"
    }
    
    func initUSerData(value : UserMainData)  {
          let url = URL(string: value.photo.profile_path)
          self.profile_pic.sd_setImage(with: url)
          name.text = value.name
          followers.text = "\(value.followers)"
          following.text = "\(value.followings)"
          posts.text = "\(value.posts)"
          ratings.text = value.rating

      }
    func getUserData() {
        RestDataSource.postUserMainData(user_id: UserDefaults.user_id!)
           .showLoading(on: self.view)
           .subscribe(onNext: { [weak self] value in
               self?.initUSerData(value: value)
           }).disposed(by: rx.bag)
    }
    func getWalletBalanceData() {
            RestDataSource.getWalletBalance(user_id: UserDefaults.user_id!)
              .showLoading(on: self.view)
              .subscribe(onNext: { [weak self] value in
                self?.coins_earned.text = value.referral_balance
                self?.setLevel(referral_balance: value.referral_balance as NSString)
              }).disposed(by: rx.bag)
      }
    func getTopEarnersData() {
        RestDataSource.postTopEarners(user_id: UserDefaults.user_id!)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.friend_earners = value.friend_earners
                self?.city_earners = value.city_earners
                self?.cityTableView.reloadData()
                self?.friends.reloadData()
            }).disposed(by: rx.bag)
    }
    func setLevel(referral_balance : NSString) {
        if(referral_balance.intValue >= 10000) {
            lbllevel.text = "01"
        }
        if(referral_balance.intValue >= 20000) {
           lbllevel.text = "02"
        }
        if(referral_balance.intValue >= 30000) {
           lbllevel.text = "03"
        }
        if(referral_balance.intValue >= 40000) {
            lbllevel.text = "04"
        }
        if(referral_balance.intValue >= 50000) {
            lbllevel.text = "05"
        }
        if(referral_balance.intValue >= 60000) {
            lbllevel.text = "06"
        }
        if(referral_balance.intValue >= 70000) {
            lbllevel.text = "07"
        }
        if(referral_balance.intValue >= 80000) {
             lbllevel.text = "08"
        }
        if(referral_balance.intValue >= 90000) {
             lbllevel.text = "09"
        }
        if(referral_balance.intValue >= 100000) {
             lbllevel.text = "010"
        }
    }
    func lblMakeMoneyText(){
        let stringValue = "You make money by earning\nReputation Coins\nin 1, 2, 3 steps…"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "money", withColor: hexStringToUIColor(hex: "#1A73E8"),fontSize:18,fontName:"Poppins-SemiBold")
        attributedString.setColorForText(textForAttribute: "Reputation Coins", withColor: hexStringToUIColor(hex: "#CC5800"),fontSize:22,fontName:"Poppins-Bold")
        attributedString.setColorForText(textForAttribute: "in 1, 2, 3 steps…", withColor: hexStringToUIColor(hex: "#535353"),fontSize:15,fontName:"Poppins-Regular")
        lblMakeMoney.attributedText = attributedString
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cityTableView  {
            return city_earners.count
        } else if tableView == friends {
            return friend_earners.count
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
            cell.name.text = city_earners[indexPath.row].name
            cell.coins.text = city_earners[indexPath.row].total_points
            let url = URL(string: city_earners[indexPath.row].photo.original_path)
            cell.photo.sd_setImage(with: url)
            return cell
        } else if tableView == friends {

            let cell = friends.dequeueReusableCell(withIdentifier: "friends_cell",
            for: indexPath as IndexPath) as! CityTableViewCell
            cell.name.text = friend_earners[indexPath.row].name
            cell.coins.text = friend_earners[indexPath.row].total_points
            let url = URL(string: friend_earners[indexPath.row].photo.original_path)
            cell.photo.sd_setImage(with: url)
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension NSMutableAttributedString {

    func setColorForText(textForAttribute: String, withColor color: UIColor,fontSize :Float,fontName : String) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        self.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName, size: CGFloat(fontSize))!, range: range)

    }
}
