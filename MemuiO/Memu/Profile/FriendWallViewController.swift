//
//  ProfileWallViewController.swift
//  Memu
//
//  Created by Tejaswini N on 16/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation
import SwiftLocation

class FriendWallViewController: UIViewController,UITableViewDataSource,UITableViewDelegate ,MGLMapViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegate{

    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var no_friend_list: UILabel!
    @IBOutlet weak var friends_list: UICollectionView!

    @IBOutlet weak var btnAddFriend: UIButton!
    @IBOutlet weak var ratings: UILabel!
     @IBOutlet weak var following: UILabel!
     @IBOutlet weak var followers: UILabel!
     @IBOutlet weak var posts: UILabel!
     @IBOutlet weak var name: UILabel!
     @IBOutlet weak var profile_pic: roundImageView!
    @IBOutlet weak var posts_relative: UITableView!
    @IBOutlet weak var scrollview: UIScrollView!
    var friend_lis = [Friend]()
    var user_Wall = [UserWall]()
    @IBOutlet weak var ridesShared: UILabel!
       @IBOutlet weak var distance_covered: UILabel!
    var type = "public"
    var friend_id = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        posts_relative.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserData()
        getUserWall()
        getFriendList()
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func initUSerData(value : UserMainData)  {
        let url = URL(string: value.photo.profile_path)
        self.profile_pic.sd_setImage(with: url)
        name.text = value.name
        followers.text = "\(value.followers)"
        following.text = "\(value.followings)"
        posts.text = "\(value.posts)"
        ratings.text = value.rating
        ridesShared.text = "\(value.rides_shared)"
        distance_covered.text = value.distance_shared
    }
    
    func FriendRequest(type : String) {
        RestDataSource.postFriendRequest(type: type, friend_id: (friend_id))
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if(value.status == "success") {
                var rightImage = "myfriends"
                if(type == "FL") {
                    rightImage = "followers_noti"
                }
                self?.showAlert(title: value.message, userName: value.user_details.name, userImage:  value.user_details.photo.original_path, rightImage: UIImage(named: rightImage)!, isAccept: false, friend_id: "", Notifications: Notifications())
                self?.getUserWall()
            } else {
                self?.showAlert("", value.message)
            }
        }).disposed(by: rx.bag)
    }
    
    func getUserWall() {
        RestDataSource.postUserWall(type: type, friend_id: (friend_id))
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.user_Wall = value.activities
            self?.friendList()
            if(value.is_freind) {
                self?.btnAddFriend.setTitle("Friends", for: .normal)
            }
            if(value.is_follower) {
                self?.btnFollow.setTitle("Following", for: .normal)
            }
        }).disposed(by: rx.bag)
    }
    
    func friendList() {
        self.posts_relative.frame.size.height = CGFloat(380 * user_Wall.count)
       self.posts_relative.reloadData()
       self.posts_relative.layoutIfNeeded()
       self.posts_relative.setNeedsFocusUpdate()
        self.scrollview.contentSize = CGSize(width:
            UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+380*CGFloat(user_Wall.count))
       posts_relative.estimatedRowHeight = 380
    }
    func getFriendList() {
        RestDataSource.postFriendList(type: "FR", request: "to_me",search_word: "",searchByLoc: 0, user_id: friend_id)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.friend_lis = value.user_list

            self?.no_friend_list.text = value.message
            if(self?.friend_lis.count != 0) {
                self?.friends_list.isHidden = false
                self?.no_friend_list.isHidden = true
            } else {
                self?.friends_list.isHidden = true
                self?.no_friend_list.isHidden = false
            }
            self?.friends_list.dataSource = self
            self?.friends_list.delegate = self
            self?.friends_list.reloadData()

        }).disposed(by: rx.bag)
    }
    func getUserData() {
        RestDataSource.postUserMainData(user_id: friend_id)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.initUSerData(value: value)
        }).disposed(by: rx.bag)
    }
    @IBAction func followers(_ sender: Any) {
       FriendRequest(type: "FL")

    }
    @IBAction func addFriend(_ sender: Any) {
        FriendRequest(type: "FR")
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = posts_relative.dequeueReusableCell(withIdentifier: "posts_cell",
                                                      for: indexPath as IndexPath) as! PostsTableViewCell
        let url = URL(string: self.user_Wall[indexPath.row].user_info.photo.profile_path)
        let post_img_url = URL(string: self.user_Wall[indexPath.row].image.profile_path)

        cell.profile_pic.sd_setImage(with: url)
        cell.name.text = self.user_Wall[indexPath.row].user_info.name
        cell.post_img.sd_setImage(with: post_img_url)
        cell.description_txt.text = self.user_Wall[indexPath.row].message
        if(self.user_Wall[indexPath.row].type == "map_feeds") {
            cell.map_view.isHidden = false
            cell.post_img.isHidden = true
            print("user_Wall longitude \(self.user_Wall[indexPath.row])")
             cell.map_view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cell.map_view.delegate = self

            addMArker(longitude: (self.user_Wall[indexPath.row].address.longitude as NSString).doubleValue, lattitude:(self.user_Wall[indexPath.row].address.lattitude as NSString).doubleValue , map_view: cell.map_view, image: self.user_Wall[indexPath.row].logo)
    
        } else {
            cell.map_view.isHidden = true
            cell.post_img.isHidden = false

        }
        return cell
    }
 
    func addMArker(longitude : Double , lattitude : Double,map_view : MGLMapView,image : String) {
        print("user_Wall longitude \(longitude) lattitude \(lattitude) image \(image)")

        let point = CustomPointAnnotation(coordinate: CLLocationCoordinate2DMake(lattitude, longitude),
                        title: "Custom Point Annotation",
                        subtitle: nil)
                    // Set the custom `image` and `reuseIdentifier` properties, later used in the `mapView:imageForAnnotation:` delegate method.
                    point.reuseIdentifier = image
                   
                    let imageURL = URL(string: image)
                    let task = URLSession.shared.dataTask(with: imageURL!) { data, response, error in

                        guard let data = data, error == nil else { return }
                     
                        DispatchQueue.main.async() {
                            if let image : UIImage = UIImage(data: data) {
                                point.image = image
                                point.image = self.resizeImage(image: point.image!, targetSize: CGSize(width: 100.0, height: 100.0))
                                map_view.addAnnotation(point)
                                map_view.setCenter(CLLocationCoordinate2DMake(lattitude, longitude), zoomLevel: 12, animated: false)
                                print("profile_picture data \(data) error \(error)")
                            }
                        }
                    }

                    task.resume()
                    //profile_picture.sd_setImage(with: imageURL)
                    
                    
        //            let annotation = MGLPointAnnotation()
        //            annotation.coordinate = CLLocationCoordinate2D(latitude: (feed.lattitude as NSString).doubleValue, longitude: (feed.longitude as NSString).doubleValue)
        //            mapView.addAnnotation(annotation)
                
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
      let size = image.size

      let widthRatio  = targetSize.width  / size.width
      let heightRatio = targetSize.height / size.height

      // Figure out what our orientation is, and use that to form the rectangle
      var newSize: CGSize
      if(widthRatio > heightRatio) {
          newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
      } else {
          newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
      }

      // This is the rect that we've calculated out and this is what is actually used below
      let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

      // Actually do the resizing to the rect using the ImageContext stuff
      UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
      image.draw(in: rect)
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return newImage!
  }
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
      if let point = annotation as? CustomPointAnnotation,
          let image = point.image,
          let reuseIdentifier = point.reuseIdentifier {

          if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
              // The annotatation image has already been cached, just reuse it.
              return annotationImage
          } else {
              // Create a new annotation image.
              return MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
          }
      }

      // Fallback to the default marker image.
      return nil
  }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friend_lis.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
            let cell = friends_list.dequeueReusableCell(withReuseIdentifier: "friends_cell", for: indexPath as IndexPath) as! FriendsCollectionViewCell
            print("getFriendList value cellForItemAt \(friend_lis.count)")

            let url = URL(string: friend_lis[indexPath.row].photo.profile_path)
            cell.profile_pic.sd_setImage(with: url)
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "FriendWallViewController") as! FriendWallViewController
         mainVC.friend_id = friend_lis[indexPath.row].freind_id
         self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 380
       }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.user_Wall.count)
      }
}
