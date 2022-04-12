//
//  FriendsViewController.swift
//  Memu
//
//  Created by Tejaswini N on 16/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var accepted_friends: UITableView!
    @IBOutlet weak var pending_friend_list: UITableView!
    
    @IBOutlet weak var no_list_found: UILabel!
    @IBOutlet weak var ratings: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    var pending_list = [Friend]()
    var friend_list = [Friend]()
    var pending_friend_list_y = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()
         accepted_friends.estimatedRowHeight = 70
         accepted_friends.rowHeight = UITableView.automaticDimension
        pending_friend_list.estimatedRowHeight = 70
        pending_friend_list.rowHeight = UITableView.automaticDimension
        pending_friend_list_y = pending_friend_list.frame.origin.y
       
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserData()
        getFriendList()
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func getUserData() {
        RestDataSource.postUserMainData(user_id: UserDefaults.user_id!)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.initUSerData(value: value)
        }).disposed(by: rx.bag)
    }
    func getFriendList() {
        RestDataSource.postFriendList(type: "FR", request: "to_me",search_word: "",searchByLoc: 0, user_id: UserDefaults.user_id ?? "")
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            print("getFriendList value")
            self?.friend_list = value.user_list
            self?.friendList()
            self?.getPendingList()
            if(value.user_list.count != 0) {
                self?.no_list_found.isHidden = true
            } else {
                self?.no_list_found.isHidden = false
                self?.no_list_found.text = value.message
            }
        }).disposed(by: rx.bag)
    }
    
    func getPendingList() {
        RestDataSource.postPendingList(type: "FR", request: "to_me")
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.pending_list = value.user_list
            self?.pendingList()
        }).disposed(by: rx.bag)
    }
    
    func friendList() {
        self.accepted_friends.frame.size.height = CGFloat(70 * 3)
        self.accepted_friends.reloadData()
        self.accepted_friends.layoutIfNeeded()
        self.accepted_friends.setNeedsFocusUpdate()
    }
    
    func  pendingList ()  {
        self.pending_friend_list.reloadData()
        self.pending_friend_list.layoutIfNeeded()
        self.pending_friend_list.setNeedsFocusUpdate()
        self.pending_friend_list.frame = CGRect(x:0, y: pending_friend_list_y + CGFloat(50) , width:self.pending_friend_list.frame.size.width, height:CGFloat(70 * pending_list.count));
        self.scrollview.contentSize = CGSize(width:
            UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + CGFloat(70 * friend_list.count ))
              
    }
    @objc func RemoveFriend(_ sender: UIButton) {
        self.RemoveFollowerAPI(friend_id: friend_list[sender.tag].freind_id,type: "Remove")
    }
    @objc func AcceptFriend(_ sender: UIButton) {
           self.RemoveFollowerAPI(friend_id: pending_list[sender.tag].freind_id,type: "Accepted")
       }
    func RemoveFollowerAPI(friend_id : String,type:String) {
        RestDataSource.postAcceptRemove(type: "FR", freind_id: friend_id, status: type)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
         self?.getFriendList()
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == accepted_friends {
        return friend_list.count
    } else {
        return pending_list.count
    }

   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == accepted_friends {

        let cell = accepted_friends.dequeueReusableCell(withIdentifier: "friend_list_one",
                                                     for: indexPath as IndexPath) as! FriendsTableViewCell
        cell.name.text = friend_list[indexPath.row].name
        let url = URL(string: friend_list[indexPath.row].photo.profile_path)
        cell.profile_pic.sd_setImage(with: url)
        cell.btnAcceptRemove.tag = indexPath.row
        cell.btnAcceptRemove.addTarget(self, action: #selector(RemoveFriend), for: .touchUpInside)

        return cell

    } else {
           let cell = pending_friend_list.dequeueReusableCell(withIdentifier: "friend_list_two",
                                                        for: indexPath as IndexPath)as! FriendsTableViewCell
            cell.name.text = pending_list[indexPath.row].name
            let url = URL(string: pending_list[indexPath.row].photo.profile_path)
            cell.profile_pic.sd_setImage(with: url)
            cell.btnAcceptRemove.tag = indexPath.row
            cell.btnAcceptRemove.addTarget(self, action: #selector(AcceptFriend), for: .touchUpInside)

           return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if tableView == accepted_friends {
                let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "FriendWallViewController") as! FriendWallViewController
                 mainVC.friend_id = friend_list[indexPath.row].freind_id
                 self.navigationController?.pushViewController(mainVC, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "FriendWallViewController") as! FriendWallViewController
                 mainVC.friend_id = pending_list[indexPath.row].freind_id
                 self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }
}
