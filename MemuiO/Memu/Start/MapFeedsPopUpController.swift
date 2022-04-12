//
//  MapFeedsPopUpController.swift
//  Memu
//
//  Created by Tejaswini N on 17/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import SwiftLocation
import CoreLocation
class MapFeedsPopUpController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  ,UICollectionViewDelegateFlowLayout{
    var map_feeds = [AlertMapFeeds]()
    @IBOutlet weak var collection_view: UICollectionView!
    var user: UserInfo!

    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        getMapFeedsList()
        user = UserInfo()

        let flow = collection_view.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        flow.minimumInteritemSpacing = 0
    }
    
    @IBAction func backbtn(_ sender: Any) {
        removeAnimate()
    }
    
    func getMapFeedsList() {
        RestDataSource.mapFeedspopupList()
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success" {
                self?.collection_view.delegate =  self
                self?.collection_view.dataSource = self
                self?.map_feeds = value.map_feeds
                self?.map_feeds.insert(AlertMapFeeds(), at: 1)
            } else {
                self?.showAlert(value.status, value.message)
            }
        }).disposed(by: rx.bag)
    }
    func addMapFeedsList(address : [String: Any],feed_id : String) {
        self.removeAnimate()
        RestDataSource.addmapFeeds(address: address,feed_id: feed_id)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success" {
                
                NotificationCenter.default.post(name: Notification.Name("showNotify"), object: nil, userInfo:nil)

            } else {
                self?.showAlert(value.status, value.message)
            }
        }).disposed(by: rx.bag)
    }
    func updateUI(feed_id : String) {

        let coordinates = CLLocationCoordinate2D(latitude: UserDefaults.latitude!, longitude: UserDefaults.longitude!)
        LocationManager.shared.locateFromCoordinates(coordinates, result: { result in
            switch result {
            case .failure(let error):
                debugPrint("An error has occurred: \(error)")
            case .success(let places):
                print("Found \(places.count) places!")
                for place in places {
                    let address = Address()
                    address.lattitude = "\(coordinates.latitude)"
                    address.longitude = "\(coordinates.longitude)"
                    address.formattedAddress = place.formattedAddress ?? ""
                     self.user.address.append(address)
                    print("formattedAddress \(address.toParams())")
                    if(address.toParams().count != 0) {
                        self.addMapFeedsList(address: address.toParams(),feed_id: feed_id)
                    } else {
                        self.showAlert("fail","Please enable your location service and retry")
                    }
                }
            }
        })
    }
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return map_feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            let numberofItem: CGFloat = 3
            
            let collectionViewWidth = self.collection_view.bounds.width
            
            let extraSpace = (numberofItem - 1) * flowLayout.minimumInteritemSpacing
            
            let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left
            
            let width = Int((collectionViewWidth - extraSpace - inset) / numberofItem)
                        
            return CGSize(width: width, height: width - 10 )
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapfeeds", for: indexPath as IndexPath) as! MapFeedsCollectionViewCell
        if(!map_feeds[indexPath.row].name.isEmpty) {
            cell.feed_title.text = map_feeds[indexPath.row].name
            let imageURL = URL(string: map_feeds[indexPath.row].logo_wt_pin)!
            cell.feed_img.sd_setImage(with: imageURL)
        }
        if(indexPath.row == 2) {
            cell.isHidden = true
        }

        return cell
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
    // MARK: - UICollectionViewDelegate protocol

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row != 2) {
            updateUI(feed_id: map_feeds[indexPath.row].id)
        }
        // handle tap events
        
        print("You selected cell #\(map_feeds[indexPath.row].name)!")
    }
}
