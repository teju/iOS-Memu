//
//  FriendsViewController.swift
//  Memu
//
//  Created by Tejaswini N on 16/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var accepted_friends: UITableView!
    @IBOutlet weak var pending_friend_list: UITableView!
    
    @IBOutlet weak var underline: UILabel!
    @IBOutlet weak var no_list_found: UILabel!
    
    @IBOutlet weak var ratings: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    var my_followers = [Friend]()
    var i_follow_list = [Friend]()
    var pending_friend_list_y = CGFloat(0)
    var underline_y = CGFloat(0)
    var i_follow_y = CGFloat(0)
    @IBOutlet weak var i_follow: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
         accepted_friends.estimatedRowHeight = 70
         accepted_friends.rowHeight = UITableView.automaticDimension
        pending_friend_list.estimatedRowHeight = 70
        pending_friend_list.rowHeight = UITableView.automaticDimension
        pending_friend_list_y = pending_friend_list.frame.origin.y + 50
        underline_y = underline.frame.origin.y
        i_follow_y = i_follow.frame.origin.y
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserData()
        getMyFollowersList()
    }
    
    func getUserData() {
        RestDataSource.postUserMainData(user_id: UserDefaults.user_id!)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.initUSerData(value: value)
        }).disposed(by: rx.bag)
    }
    
    func getMyFollowersList() {
        RestDataSource.postPendingList(type: "FL", request: "to_me")
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in

            self?.my_followers = value.user_list
            self?.friendList()
            self?.getIFollowList()
            if(value.user_list.count != 0) {
                self?.no_list_found.isHidden = true
            } else {
                self?.no_list_found.isHidden = false
                self?.no_list_found.text = value.message
            }
        }).disposed(by: rx.bag)
    }
    
    func getIFollowList() {
        RestDataSource.postPendingList(type: "FL", request: "by_me")
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.i_follow_list = value.user_list
            self?.pendingList()
        }).disposed(by: rx.bag)
    }
    func RemoveFollowerAPI(friend_id : String) {
        RestDataSource.postAcceptRemove(type: "FL", freind_id: friend_id, status: "Remove")
           .showLoading(on: self.view)
           .subscribe(onNext: { [weak self] value in
            if(value.status == "success") {
                self?.getMyFollowersList()
            } else {
                self?.showAlert("", value.message)

            }
           }).disposed(by: rx.bag)
       }
    func friendList() {
        self.accepted_friends.frame.size.height = CGFloat(70 * my_followers.count)
        self.accepted_friends.reloadData()
        self.accepted_friends.layoutIfNeeded()
        self.accepted_friends.setNeedsFocusUpdate()
    }
    
    func  pendingList ()  {
        if(my_followers.count != 0) {
            pending_friend_list_y = (pending_friend_list.frame.origin.y)
        }

        self.pending_friend_list.reloadData()
        self.pending_friend_list.layoutIfNeeded()
        self.pending_friend_list.setNeedsFocusUpdate()
        self.pending_friend_list.frame = CGRect(x:0, y:self.pending_friend_list_y + CGFloat(60) * (CGFloat(my_followers.count) - 1) , width:self.pending_friend_list.frame.size.width, height:CGFloat(70 * i_follow_list.count));
        self.scrollview.contentSize = CGSize(width:
            UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + CGFloat(70 * my_followers.count ))
        if(my_followers.count != 0) {
            i_follow.frame.origin.y = i_follow_y + (CGFloat(my_followers.count) - 1) * 60
            underline.frame.origin.y = underline_y + (CGFloat(my_followers.count) - 1) * 60 

        } 
              
    }
     @objc func RemoveFollower(_ sender: UIButton) {
        self.RemoveFollowerAPI(friend_id: my_followers[sender.tag].freind_id)
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
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == accepted_friends {
        return my_followers.count
    } else {
        return i_follow_list.count
    }

   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == accepted_friends {

        let cell = accepted_friends.dequeueReusableCell(withIdentifier: "friend_list_one",
                                                     for: indexPath as IndexPath) as! FriendsTableViewCell
        cell.name.text = my_followers[indexPath.row].name
        let url = URL(string: my_followers[indexPath.row].photo.profile_path)
        cell.profile_pic.sd_setImage(with: url)
        cell.btnAcceptRemove.tag = indexPath.row

        cell.btnAcceptRemove.addTarget(self, action: #selector(RemoveFollower), for: .touchUpInside)

        return cell

    } else {
           let cell = pending_friend_list.dequeueReusableCell(withIdentifier: "friend_list_two",
                                                        for: indexPath as IndexPath) as! FriendsTableViewCell
           cell.name.text = i_follow_list[indexPath.row].name
           let url = URL(string: i_follow_list[indexPath.row].photo.profile_path)
           cell.profile_pic.sd_setImage(with: url)
           cell.btnAcceptRemove.tag = indexPath.row
            cell.btnAcceptRemove.addTarget(self, action: #selector(RemoveFollower), for: .touchUpInside)

            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if tableView == accepted_friends {
                let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "FriendWallViewController") as! FriendWallViewController
                 mainVC.friend_id = my_followers[indexPath.row].freind_id
                 self.navigationController?.pushViewController(mainVC, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "FriendWallViewController") as! FriendWallViewController
                 mainVC.friend_id = i_follow_list[indexPath.row].freind_id
                 self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }
}
