//
//  WalletViewController.swift
//  Memu
//
//  Created by Tejaswini N on 19/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit
class WalletViewController: UITableViewController {
    @IBOutlet weak var total_balance: UILabel!
    var merchant:PGMerchantConfiguration!
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
        getTopEarnersData()
    }
    
    func getTopEarnersData() {
        let randomInt = Int.random(in: 1..<10000)

       orderDict["MID"] = "EYZGKu85499319132530";//paste here your merchant id   //mandatory
       orderDict["CHANNEL_ID"] = "WAP";
       orderDict["INDUSTRY_TYPE_ID"] = "Retail";
       orderDict["WEBSITE"] = "DEFAULT";
        if let amountDidgit = amount.text {
            orderDict["TXN_AMOUNT"] = amountDidgit.digits
        }
       orderDict["ORDER_ID"] = "OREDRID_\(randomInt)";
        orderDict["CUST_ID"] = UserDefaults.user_id;
        orderDict["CALLBACK_URL"] = "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=OREDRID_\(randomInt)"
        RestDataSource.postchecksum(checksum: orderDict)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.makePayment(CHECKSUMHASH: value.generate_signature)
            }).disposed(by: rx.bag)
    }
    
    func makePayment(CHECKSUMHASH : String){
            merchant = PGMerchantConfiguration.default()
           orderDict["CHECKSUMHASH"] = CHECKSUMHASH;
        print("makePayment orderDict \(orderDict)")
            let pgOrder = PGOrder(params: orderDict )
            let transaction = PGTransactionViewController.init(transactionFor: pgOrder)
                transaction!.serverType = eServerTypeProduction
                transaction!.merchant = merchant
                transaction!.delegate = self
                transaction?.loggingEnabled = true
                self.navigationController?.pushViewController(transaction!, animated: true)
        }
        
    }

    /*all actions related to transaction are catched here*/
    extension WalletViewController : PGTransactionDelegate{
        func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
            print(response)
            self.showAlert("Transaction Successfull",NSString.localizedStringWithFormat("Response- %@", response) as String)

            getRecharge()
        }


        func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
            print("didFailTransaction \(error)")
            self.showAlert("Transaction Failed",error.localizedDescription)
        }
        func didCancelTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
            
            self.showAlert("Transaction Failed", error.localizedDescription)

        }
        
        func didFinishCASTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
            print(response)
            self.showAlert("cas", "")
        }
        
        

    }

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
