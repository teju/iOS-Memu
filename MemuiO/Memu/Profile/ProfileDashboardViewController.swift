//
//  ProfileDashboardViewController.swift
//  Memu
//
//  Created by Tejaswini N on 09/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class ProfileDashboardViewController: UIViewController,UICollectionViewDataSource,
UICollectionViewDelegate{
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var ratings: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    @IBOutlet weak var followers_count: UILabel!
    @IBOutlet weak var friends_count: UILabel!
    @IBOutlet weak var friends_list: UICollectionView!
    var friend_lis = [Friend]()
    @IBOutlet weak var no_friend_list: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollview.contentSize = CGSize(width:
        UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*2 - 200)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserData()
        getFriendList()
    }
    @IBAction func followers(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
          let mainVC = storyboard.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
           self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
    @IBAction func friends(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "FriendsViewController") as! FriendsViewController
         self.navigationController?.pushViewController(mainVC, animated: true)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func myProfile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "ProfileWallViewController") as! ProfileWallViewController
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
    @IBAction func findMore(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
           let mainVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            self.navigationController?.pushViewController(mainVC, animated: true)
    }
  
    func getFriendList() {
        RestDataSource.postFriendList(type: "FR", request: "to_me",search_word: "",searchByLoc: 0, user_id: UserDefaults.user_id ?? "")
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
        RestDataSource.postUserMainData(user_id: UserDefaults.user_id!)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.initUSerData(value: value)
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
    
       
           friends_count.textColor = UIColor.white
           friends_count.text = "\(value.friends)"
           followers_count.textColor = UIColor.white
           followers_count.text = "\(value.followers)"
       
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
    @IBAction func myEarnings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
         self.navigationController?.pushViewController(mainVC, animated: true)
    }
    @IBAction func refreealAdd(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "ReferralAddViewController") as! ReferralAddViewController
        self.navigationController?.pushViewController(mainVC, animated: true)
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
    @IBAction func settings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
         self.navigationController?.pushViewController(mainVC, animated: true)
    }
}
