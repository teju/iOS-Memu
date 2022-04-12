//
//  WalletViewController.swift
//  Memu
//
//  Created by Tejaswini N on 19/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit
import AppInvokeSDK
class WalletViewController: UITableViewController ,AIDelegate{
    func openPaymentWebVC(_ controller: UIViewController?) {
        if let vc = controller {
            DispatchQueue.main.async {[weak self] in
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func didFinish(with status: AIPaymentStatus, response: [String : Any]) {
        print("AIPaymentStatus \(status.rawValue) response \(response)")
        if(status.rawValue  == 0) {
            getRecharge()
        } else {
            self.showAlert("", response["RESPMSG"] as! String)
        }
    }
    private let appInvokeself = AIHandler()

    @IBOutlet weak var total_balance: UILabel!
    var orderDict: [String: String] = [:]
    var wallet: [String: String] = [:]
    var walletBAlance = ""
    @IBOutlet weak var ratings: UILabel!
       @IBOutlet weak var following: UILabel!
       @IBOutlet weak var followers: UILabel!
       @IBOutlet weak var posts: UILabel!
       @IBOutlet weak var name: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var profile_pic: roundImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserData()
        getWalletData()
        amount.setUnderLine()
       
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func thousand(_ sender: Any) {
        if let amountDidgit = amount.text {
            let amt = (amountDidgit as NSString).intValue + 1000
            amount.text = "\(amt)"
        }
       
    }
    
    @IBAction func fivehundred(_ sender: Any) {
        if let amountDidgit = amount.text {
            let amt = (amountDidgit as NSString).intValue + 500
            amount.text = "\(amt)"
        }
    }
    @IBAction func towhundred(_ sender: Any) {
        if let amountDidgit = amount.text {
                   let amt = (amountDidgit as NSString).intValue + 200
                   amount.text = "\(amt)"
               }
    }
    func getUserData() {
        RestDataSource.postUserMainData(user_id: UserDefaults.user_id!)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.initUSerData(value: value)
        }).disposed(by: rx.bag)
    }
    func getTokenData() {
        RestDataSource.postUserMainData(user_id: UserDefaults.user_id!)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.initUSerData(value: value)
        }).disposed(by: rx.bag)
    }
    func getWalletData() {
        RestDataSource.postWalletData(user_id: UserDefaults.user_id!)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.total_balance.text = value.balance
            self?.walletBAlance = value.balance
        }).disposed(by: rx.bag)
    }
    
    func getRecharge() {
        wallet["credit_amount"] = amount.text?.digits;
        wallet["wallet_balance"] = walletBAlance

        RestDataSource.postpayment(wallet: wallet, mode: "wallet")
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.getWalletData()
        }).disposed(by: rx.bag)
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
    
    @IBAction func recharge(_ sender: Any) {
       getRechargeWallet()
    }
    
    func getRechargeWallet() {
        
        let randomInt = Int.random(in: 1..<10000)

       orderDict["MID"] = "EYZGKu85499319132530";//paste here your merchant id   //mandatory
        if let amountDidgit = amount.text {
            orderDict["amount"] = amountDidgit.digits
        }
       orderDict["orderId"] = "OREDRID_\(randomInt)";
        RestDataSource.postchecksum(paytm_params: orderDict)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.gotoPaytm(txnToken: value.body.txnToken, orderID: (self?.orderDict["orderId"]!)!)
        }).disposed(by: rx.bag)
        
    }
    func gotoPaytm(txnToken :String,orderID : String) {
        self.appInvokeself.restrictAppInvokeFlow(restrict: true)
         self.appInvokeself.openPaytm(merchantId: "EYZGKu85499319132530", orderId: orderID, txnToken: txnToken,amount: self.amount.text!.digits, callbackUrl: "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=\(orderID)", delegate: self, environment: AIEnvironment.production)
    }
    @IBAction func invite(_ sender: Any) {
        let text = "Hey, try this app! a nice replacement to Google Maps. We can also earn reputation coins & money. Wow!\nUse my code - \(UserDefaults.referel_code ?? "") \nhttps://play.google.com/store/apps/details?id=com.memu"

        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)

    }
}

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
