//
//  SettingsViewController.swift
//  Memu
//
//  Created by Tejaswini N on 11/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftyJSON

class SettingsViewController: UITableViewController,UICollectionViewDelegate,UICollectionViewDataSource,AddAssetButtonViewDelegate {
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnUpload: AddAssetButtonView!
    @IBOutlet weak var profile_pic: roundImageView!
    
    @IBOutlet weak var btnMale: UIButton!
    private var isUpload = false

    @IBOutlet weak var btnOfficeAddress: UIButton!
    @IBOutlet weak var btnHomeAddress: UIButton!
    @IBOutlet weak var vehicletable: UICollectionView!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var drivinfLL: UITextField!

    @IBOutlet weak var workEmail: UITextField!
    @IBOutlet weak var personalEmail: UITextField!
    @IBOutlet weak var mobile_number: UITextField!
    @IBOutlet weak var name: UITextField!
    var userProfile :UserProfile!
    var vehicle = [Vehicle]()
    var VehicleCount = 0
    var btn = UIButton(type: .custom)
    private var tag = 0
    var addrDic = [Address]()
    var vehicleParam = [Vehicle]()
    var userDic: [String: Any] = [:]
    var gender = ""
    let selectedimage = UIImage(named: "Tickbox-1")
    let unselectedimage = UIImage(named: "TICKBOX")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drivinfLL.setUnderLine()
        btnHomeAddress.setUnderLine()
        btnOfficeAddress.setUnderLine()
        workEmail.setUnderLine()
        personalEmail.setUnderLine()
        mobile_number.setUnderLine()
        name.setUnderLine()
        lastname.setUnderLine()
        getProfileData()
        floatingButton()
        vehicletable.register(VehicleTableViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "vehicle")
        btnUpload.delegate = self

    }
    func addAssetButtonTapped(_ view: AddAssetButtonView) {
        btnUpload.addAssetButtonTapped(btnUpload)
    }
    
    func addAssetImageChanged(_ image: UIImage, filename: String, modalDismissed: Bool) {
        btnUpload.imageView?.image = nil
        
        if !isUpload {
            uploadImage(image)
            isUpload = true
        }
    }
   
    private func uploadImage(_ image: UIImage) {
    
        RestDataSource.uploadImage(url: "\(RestDataSource.appBaseUrl)profile/update-profile-image", image: image, param: "profile").showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            UserDefaults.profile_picture = value.profile_path
            print("profile_pic \(UserDefaults.profile_picture!) profile_path \(value)")

            let url = URL(string: UserDefaults.profile_picture!)
            self?.profile_pic.sd_setImage(with: url)
           
        }).disposed(by: rx.bag)
    }
    @IBAction  func selectGender(_ sender: UIButton) {
      

        switch sender.tag {
           case 0:
               gender = "Male"
               btnFemale.setImage(selectedimage, for: .normal)
               btnMale.setImage(unselectedimage, for: .normal)
           case 1:
               gender = "Female"
               btnMale.setImage(selectedimage, for: .normal)
               btnFemale.setImage(unselectedimage, for: .normal)
           default:
               return
           }
       }
   
    func prepareParams() {
        userDic =
        ["mobile": mobile_number.text ?? "",
        "first_name": name.text ?? "",
        "last_name": lastname.text ?? "",
        "office_email": workEmail.text ?? "",
        "dl_number": drivinfLL.text ?? "",
        "gender": gender,
        "email": personalEmail.text ?? ""]
        
        for var i in 0..<vehicle.count {
            let index = IndexPath(row: i, section: 0)
            let cell: VehicleTableViewCell = self.vehicletable.cellForItem(at: index) as! VehicleTableViewCell
            let vehicleM =  Vehicle()
            vehicleM.vehicleNo = cell.reg_no.text ?? ""
            vehicleM.vehicleName = cell.model.text ?? ""
            vehicleM.vehicleModelType = cell.type.text ?? ""
            vehicleM.vehicleBrand = cell.brand.text ?? ""
            if(cell.yellowboard.isChecked) {
                vehicleM.vehicleType = 1
            } else if(cell.whiteboard.isChecked){
                vehicleM.vehicleType = 2
            }
            vehicleM.id = vehicle[i].id
            vehicleParam.append(vehicleM)
        }

       let dict: [String: Any] = ["user_id":UserDefaults.user_id,"userInfo": self.userDic,"Vehicle":self.vehicleParam.map{ $0.toParams() },"Address":self.addrDic.map{ $0.toParams2()}]
              print("userDic dict  \(dict)")
       self.saveProfileData(userDic: dict)
    }
    
    func gettoAddress(coordinate : CLLocationCoordinate2D,id : String, type : String){
        let address = Address()
        if(!id.isEmpty) {
            address.id = id
        }
       address.type = type
       address.lattitude = "\(coordinate.latitude)"
       address.longitude = "\(coordinate.longitude)"

       var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
         let ceo: CLGeocoder = CLGeocoder()
         center.latitude = coordinate.latitude
         center.longitude = coordinate.longitude

         let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
         ceo.reverseGeocodeLocation(loc, completionHandler:
             {(placemarks, error) in
                 if (error != nil)
                 {
                     print("reverse geodcode fail: \(error!.localizedDescription)")
                 }
                 let pm = placemarks! as [CLPlacemark]
                 var addressString = ""
                 if pm.count > 0 {
                     let pm = placemarks![0]
                    
                     if pm.subLocality != nil {
                         addressString = addressString + pm.subLocality! + ", "
                     }
                     if pm.thoroughfare != nil {
                         addressString = addressString + pm.thoroughfare! + ", "
                     }
                     if pm.locality != nil {
                         addressString = addressString + pm.locality! + ", "
                     }
                     if pm.country != nil {
                         addressString = addressString + pm.country! + ", "
                     }
                     if pm.postalCode != nil {
                         addressString = addressString + pm.postalCode! + " "
                     }
                     address.formattedAddress = addressString
                    address.country = pm.country ?? ""
                    address.state = pm.country ?? ""
                    address.pincode = pm.postalCode ?? ""
                    address.city = pm.locality ?? ""
                    self.addrDic.append(address)
                    
               }
         })
      
    }
    func floatingButton(){
        btn.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: UIScreen.main.bounds.height - 70, width: 100, height: 45)
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setBackgroundImage(UIImage(named: "btn_add_friend"), for: .normal)
        btn.addTarget(self,action: #selector(save(_:)), for: .touchUpInside)
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(btn)
        }
    }
    
    @objc func save(_ sender: Any) {
        prepareParams()
    }
   @objc func updateVehicleType(_ sender: CheckBoxButton) {
        let index = IndexPath(row: sender.tag, section: 0)

        let cell: VehicleTableViewCell = self.vehicletable.cellForItem(at: index) as! VehicleTableViewCell
       
        if(sender == cell.yellowboard) {
            vehicle[sender.tag].vehicleType = 2
        } else {
            vehicle[sender.tag].vehicleType = 1
        }
        vehicletable.reloadData()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        btn.removeFromSuperview()
    }
    func initData() {
        self.drivinfLL.text = userProfile.personal_details.dl_number
        self.btnOfficeAddress.setTitle(userProfile.address.office.formattedAddress, for: .normal)
        self.btnHomeAddress.setTitle(userProfile.address.home.formattedAddress, for: .normal)
        self.workEmail.text = userProfile.personal_details.office_email
        self.personalEmail.text = userProfile.personal_details.email
        self.mobile_number.text = userProfile.personal_details.mobile
        self.name.text = userProfile.personal_details.firstName
        self.lastname.text = userProfile.personal_details.lastName
        if(userProfile.personal_details.gender == "male") {
            gender = "Male"
            btnFemale.setImage(selectedimage, for: .normal)
            btnMale.setImage(unselectedimage, for: .normal)
        } else {
            gender = "Female"
            btnMale.setImage(selectedimage, for: .normal)
            btnFemale.setImage(unselectedimage, for: .normal)
        }
        let url = URL(string:UserDefaults.profile_picture!)

        self.profile_pic.sd_setImage(with: url)

    }
    
    func getProfileData() {
        RestDataSource.postgetProfile(user_id: UserDefaults.user_id!)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.userProfile = value
                self?.initData()
                self?.vehicle = self?.userProfile?.vehicle as! [Vehicle]
                if(self?.vehicle.count == 0) {
                    self?.vehicle.append(Vehicle())
                }
                self?.VehicleCount = self?.vehicle.count as! Int
                self?.vehicletable.dataSource = self
                self?.vehicletable.delegate = self
                self?.tableView.reloadData()
                self?.vehicletable.reloadData()
            }).disposed(by: rx.bag)
    }
   
    func saveProfileData(userDic : [String : Any]) {
        RestDataSource.postsaveProfile(userInfo: userDic)
               .showLoading(on: self.view)
               .subscribe(onNext: { [weak self] value in
                if(value.status == "success") {
                    self?.navigationController?.popViewController(animated: true)
                }
                
               }).disposed(by: rx.bag)
       }
    
    @IBAction func pickAddress(_ sender: UIButton) {
        self.tag = sender.tag
       let autocompleteController = GMSAutocompleteViewController()
       autocompleteController.delegate = self
       let searchBarTextAttributes: [NSAttributedString.Key : AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.black, NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: UIFont.systemFontSize)]
       UITextField.appearance(whenContainedInInstancesOf: [UITableView.self]).defaultTextAttributes = searchBarTextAttributes
       // Specify the place data types to return.
       let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
           UInt(GMSPlaceField.placeID.rawValue))!
       autocompleteController.placeFields = fields

       // Specify a filter.
       let filter = GMSAutocompleteFilter()
       filter.type = .noFilter
       filter.country = "IN"
       autocompleteController.autocompleteFilter = filter

       // Display the autocomplete view controller.
       present(autocompleteController, animated: true, completion: nil)
    }
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           VehicleCount
       }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if(indexPath.row == 3) {
                     vehicle.append(Vehicle())
                     VehicleCount = self.vehicle.count as! Int
                     self.vehicletable.frame = CGRect(x: vehicletable.frame.origin.x, y: vehicletable.frame.origin.y, width: vehicletable.frame.size.width, height: CGFloat(300 * VehicleCount))
                     self.tableView.reloadData()
                     self.vehicletable.reloadData()
                     
                 }
    }
      
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = vehicletable.dequeueReusableCell(withReuseIdentifier: "vehicle",
                                  for: indexPath as IndexPath) as! VehicleTableViewCell
           cell.reg_no.setUnderLine()
           cell.type.setUnderLine()
           cell.brand.setUnderLine()
           cell.model.setUnderLine()
           cell.reg_no.text = vehicle[indexPath.row].vehicleNo
           cell.type.text = vehicle[indexPath.row].vehicleModelType
           cell.brand.text = vehicle[indexPath.row].vehicleBrand
           cell.model.text = vehicle[indexPath.row].vehicleName
           if( vehicle[indexPath.row].vehicleType == 1) {
                cell.yellowboard.isChecked = false
                cell.whiteboard.isChecked = true
                cell.yellowboard.buttonClicked(sender: cell.yellowboard)
                cell.whiteboard.buttonClicked(sender: cell.whiteboard)
           } else {
               cell.yellowboard.isChecked = true
               cell.whiteboard.isChecked = false
               cell.yellowboard.buttonClicked(sender: cell.yellowboard)
               cell.whiteboard.buttonClicked(sender: cell.whiteboard)
           }
        cell.yellowboard.isUserInteractionEnabled = true
        cell.whiteboard.isUserInteractionEnabled = true

            cell.whiteboard.tag = indexPath.row
            cell.yellowboard.tag = indexPath.row
            cell.yellowboard.addTarget(self,action: #selector(updateVehicleType(_:)), for: .touchUpInside)

            cell.whiteboard.addTarget(self,action: #selector(updateVehicleType(_:)), for: .touchUpInside)

           return cell
       }
          func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: UIScreen.main.bounds.width, height: 200)
       }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.row == 2) {
            return CGFloat(280 * VehicleCount)
        } 
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
}
extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
extension SettingsViewController: GooglePlacesAutocompleteDelegate {
  func placeSelected(place: Place) {
    print(place.description)
  }

  func placeViewClosed() {
    dismiss(animated: true, completion: nil)
  }
}

extension SettingsViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.formattedAddress)")
        print("Place ID: \(place.placeID)")
        
        let placesClient = GMSPlacesClient.shared()
        placesClient.lookUpPlaceID(place.placeID!) { (place, error) in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress!)")
                print("Place placeID \(place.placeID)")
                print("Place attributions \(place.attributions)")
                print("\(place.coordinate.latitude)")
                print("\(place.coordinate.longitude)")
            
                self.dismiss(animated: true, completion: {
                    self.updateLocation(place)
                })
            }
        }
    }
    
    private func updateLocation(_ place: GMSPlace) {
        if tag == 0 {
            self.btnHomeAddress.setTitle(place.formattedAddress!, for: .normal)
            gettoAddress(coordinate: place.coordinate, id: userProfile.address.home.id, type: "home")
        } else {
            self.btnOfficeAddress.setTitle( place.formattedAddress!, for: .normal)
            gettoAddress(coordinate: place.coordinate, id: userProfile.address.office.id, type: "office")
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
