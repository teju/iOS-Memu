//
//  MatchingRidersViewController.swift
//  Memu
//
//  Created by Tejaswini N on 21/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class MatchingRidersViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var matching_riders: UITableView!
    var trip_or_rider_id = ""
    var type = ""
    @IBOutlet weak var no_list: UILabel!
    @IBAction func back(_ sender: Any) {
        removeAnimate()
    }
    var matchingBuddyResp : MatchingBuddiesResponse?
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            
        }
         getMAtchingBuddies()
    }
    func getMAtchingBuddies() {
      RestDataSource.matchingBuddiesList(trip_or_rider_id: trip_or_rider_id, type: type)
          .showLoading(on: self.view)
          .subscribe(onNext: { [weak self] value in
              if value.status == "success" {
                self?.matchingBuddyResp = value
                
                if(self?.matchingBuddyResp!.pooler_list.count == 0) {
                    self?.no_list.isHidden = false
                    self?.no_list.text = value.message
                } else {
                    self?.no_list.isHidden = true
                    self?.matching_riders.reloadData()
                }
              } else {
                self?.removeAnimate()
                  self?.showAlert(value.status, value.message)
              }
          }).disposed(by: rx.bag)
      }
    func sendRequest(to_user_id : String,type : String,id : String) {
        RestDataSource.postRequestRide(to_user_id: to_user_id, type: type, id: id)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
               // self?.showAlert(value.status, value.message)
            }).disposed(by: rx.bag)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingBuddyResp?.pooler_list.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = matching_riders.dequeueReusableCell(withIdentifier: "matching_riders", for: indexPath as IndexPath) as! MAtchingRidersTableViewCell
        cell.name.text = matchingBuddyResp?.pooler_list[indexPath.row].name
        cell.route_percent.text = "100%\nRoute"
      //  cell.route_percent.text = matchingBuddyResp?.pooler_list[indexPath.row].route_per
        cell.time.text = matchingBuddyResp?.pooler_list[indexPath.row].time
        cell.pay.text = "120\nCoins"
        cell.request.tag = indexPath.row
        if(matchingBuddyResp?.pooler_list[indexPath.row].photo.profile_path != "") {
            let imageURL = URL(string: (matchingBuddyResp?.pooler_list[indexPath.row].photo.profile_path)!)!
            cell.profile_pic.sd_setImage(with: imageURL)
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        cell.request.isUserInteractionEnabled = true
        cell.request.addGestureRecognizer(tapGestureRecognizer)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let imgView = tapGestureRecognizer.view!
        sendRequest(to_user_id:  (matchingBuddyResp?.pooler_list[imgView.tag].user_id)!, type: type, id: (matchingBuddyResp?.pooler_list[imgView.tag].id)!)
        
    }
}
