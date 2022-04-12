//
//  TripCompletedViewController.swift
//  Memu
//
//  Created by Tejaswini N on 01/03/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class TripCompletedViewController: UIViewController {
    @IBOutlet weak var lbcoins: UILabel!
    @IBOutlet weak var lbamount: UILabel!
    @IBOutlet weak var lbTimeTaken: UILabel!
    @IBOutlet weak var lbDistanceTravelled: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    var tripID = ""
    var triptype = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: UserDefaults.profile_picture!)
        self.profile_pic.sd_setImage(with: url)
        tripSummary()
    }

    func tripSummary() {
        
        RestDataSource.getTripSummary(trip_id: tripID, type: triptype)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.initData(tripsummary: value)
            }).disposed(by: rx.bag)
    }
    
    func initData(tripsummary : TripSummary) {
        lbcoins.text = tripsummary.reputation_coin
        lbamount.text = tripsummary.money_earned_spent
        lbTimeTaken.text = tripsummary.time_taken
        lbDistanceTravelled.text = tripsummary.distance_travelled
    }

    @IBAction func back(_ sender: Any) {
         let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
         self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
}
