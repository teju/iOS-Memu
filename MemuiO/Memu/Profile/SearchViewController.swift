//
//  SearchViewController.swift
//  Memu
//
//  Created by Tejaswini N on 16/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UICollectionViewDataSource,
UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var ratings: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var textfield: UITextField!
    var friend_list = [Friend]()
    @IBOutlet weak var followers_count: UILabel!
       @IBOutlet weak var friends_count: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let flow = collection_view.collectionViewLayout as! UICollectionViewFlowLayout
               
        flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
               
        flow.minimumInteritemSpacing = 0
        textfield.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: .editingChanged)

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserData()
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        getFriendList(search_word: textField.text ?? "")
        
    }
    
    func getFriendList(search_word : String) {
        RestDataSource.postSearchFriendList(search_word: search_word)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            self?.friend_list = value.user_list
            self?.collection_view.reloadData()
        }).disposed(by: rx.bag)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func followers(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
         self.navigationController?.pushViewController(mainVC, animated: true)
    }
    @IBAction func addFriend(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "FriendsViewController") as! FriendsViewController
         self.navigationController?.pushViewController(mainVC, animated: true)
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
        return friend_list.count
    }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            print("collectionViewLayout UICollectionViewLayout")
                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
                
                let numberofItem: CGFloat = 4
                
                let collectionViewWidth = self.collection_view.bounds.width
                
                let extraSpace = (numberofItem - 1) * flowLayout.minimumInteritemSpacing
                
                let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left
                
                let width = Int((collectionViewWidth - extraSpace - inset) / numberofItem)
                            
                return CGSize(width: width, height: width)
            }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            // get a reference to our storyboard cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friends_cell",
                                                          for: indexPath as IndexPath) as! FriendsCollectionViewCell
            let url = URL(string: friend_list[indexPath.row].photo.profile_path)
            cell.profile_pic.sd_setImage(with: url)
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
           let storyboard = UIStoryboard(name: "Profile", bundle: nil)
          let mainVC = storyboard.instantiateViewController(withIdentifier: "FriendWallViewController") as! FriendWallViewController
           mainVC.friend_id = friend_list[indexPath.row].id
           self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }


