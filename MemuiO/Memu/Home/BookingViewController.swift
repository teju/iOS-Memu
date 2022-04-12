//
//  BookingViewController.swift
//  Memu
//
//  Created by Tejaswini N on 19/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

import MapboxNavigation
import MapboxDirections
import Mapbox
import SDWebImage
import GooglePlaces
import CoreLocation
import SwiftLocation
import DropDown

class BookingViewController: UIViewController ,UICollectionViewDataSource,WWCalendarTimeSelectorProtocol, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var btnSelectTime: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var week_day_txt: UILabel!
    let chooseDropDown = DropDown()
    var daysarray:[String] = []
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var bg_view: UIImageView!
    
    @IBOutlet weak var mapview: MGLMapView!
    private var currentloc: CLLocationCoordinate2D! = nil
    private var destinationloc: CLLocationCoordinate2D! = nil
    @IBOutlet weak var lblCurrentLoc: UILabel!
    @IBOutlet weak var lblDestinationLoc: UILabel!
    
    @IBOutlet weak var collection_view: UICollectionView!
    private var tag = 0
    @IBOutlet weak var profile_img: UIImageView!
    let timePicker = UIDatePicker()

    @IBOutlet weak var btnseat: UIButton!
    let weekDays = ["Mo","Tu","We","Th","Fr","Sa","Su"]
    var addressStrString = ""
    var fromAddress  =  [String: Any]()
    var toAddress  = [String: Any]()
    var vehicle_id = ""
    var rs_per_km = ""
    var bookingDate = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let imageURL = URL(string: UserDefaults.profile_picture ?? "")
        profile_img.sd_setImage(with: imageURL)
        collection_view.dataSource = self
        collection_view.delegate = self
        setCurrentDate(date: Date())
        setupChooseDropDown()
        setCurrentTime()
        btnseat.setTitle("01\nSeats", for: .normal)
        btnseat.titleLabel?.textAlignment = .center
        btnSelectTime.titleLabel?.textAlignment = .center
        btnDate.titleLabel?.textAlignment = .center
        self.bg_view.frame.size.height = self.bg_view.frame.height
         NotificationCenter.default.addObserver(self, selector: #selector(self.offerRideNow(notification:)), name: Notification.Name("vehicleDeatils"), object: nil)
        updateUI()
    }
    @objc func offerRideNow(notification: Notification) {
       if(currentloc !=  nil && destinationloc != nil && vehicle_id != "" && rs_per_km != "") {
           getFromAddress(strtype: "offer_ride", strno_of_kms: "15")
       }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+420)
        
    }
    func setVehicleID(vehicle_id : String,rs_per_km : String) {
        self.vehicle_id = vehicle_id
        self.rs_per_km = rs_per_km
        //getFromAddress(strtype: "offer_ride", strno_of_kms: "16")
    }
    @IBAction func offerRide(_ sender: Any) {
        if(currentloc == nil || destinationloc == nil) {
            self.showAlert("",  "Please select source and destination")
        } else {
            print("offerRide \(vehicle_id)")
            let popvc = UIStoryboard(name: "NavigationController", bundle: nil).instantiateViewController(withIdentifier: "VehiclePopupViewController") as! VehiclePopupViewController
            popvc.parentVC = self
            self.addChild(popvc)
        
            popvc.view.frame = self.view.frame

            self.view.addSubview(popvc.view)

            popvc.didMove(toParent: self)
        }
    }
    @IBAction func history(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HistoryStoryboard", bundle: nil)
       let mainVC = storyboard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
    @IBAction func btnNext(_ sender: Any) {
        
    }
    @IBAction func findRide(_ sender: Any) {
        
        if(currentloc == nil || destinationloc == nil) {
          self.showAlert("", "Please select source and destination")
        } else {
          getFromAddress(strtype: "find_ride", strno_of_kms: "16")
        }
    }
    @IBAction func seatPicker(_ sender: Any) {
        chooseDropDown.show()
    }
    
    @IBAction func timeSelector(_ sender: Any) {
        timePicker.datePickerMode = UIDatePicker.Mode.time
      timePicker.frame = CGRect(x: 0.0, y: (self.view.frame.height - 150), width: self.view.frame.width, height: 150.0)
        timePicker.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1.000)
        
        timePicker.setValue(UIColor.black, forKeyPath: "textColor")

      self.view.addSubview(timePicker)
        timePicker.addTarget(self, action: #selector(self.startTimeDiveChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func startTimeDiveChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        btnSelectTime.setTitle(formatter.string(from: sender.date), for: .normal)
        timePicker.removeFromSuperview() // if you want to remove time picker
    }
    @IBAction func datePicker(_ sender: Any) {
        let selector = WWCalendarTimeSelector.instantiate()
        selector.optionShowTopContainer = false
        // 2. You can then set delegate, and any customization options
        selector.delegate = self
        selector.optionTopPanelTitle = "Awesome Calendar!"
        selector.optionSelectionType = .single
        // 3. Then you simply present it from your view controller when necessary!
        self.present(selector, animated: true, completion: nil)
    }
    
    func addMapFeedsList(strtype : String) {
        //let date = getDate(date: btnDate.titleLabel?.text ?? "")
    
        let time = btnSelectTime.titleLabel?.text?.replacingOccurrences(of: "\n", with: "")
        let no_of_seats = btnseat.titleLabel?.text ?? ""
        let replaced = no_of_seats.replacingOccurrences(of: "\nSeats", with: " ")
        let seats = Int(replaced) ?? 1
        let type = strtype
        let no_of_kms = (getDitance() / 1000)
        var is_recuring_ride = "no"
        if(daysarray.count != 0) {
            is_recuring_ride = "yes"
        }
        RestDataSource.findOfferRide(date: bookingDate, time: time ?? "", no_of_seats: seats, is_recuring_ride: is_recuring_ride, type: type, no_of_kms: String(format:"%.2f", no_of_kms), toaddress: toAddress, fromaddress: fromAddress, days: daysarray.joined(separator:","),vehicle_id: vehicle_id,rs_per_kms: rs_per_km)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success" {
                let storyboard = UIStoryboard(name: "NavigationController", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "AdvancedViewController") as! AdvancedViewController
                mainVC.currentLoc = self?.currentloc
                mainVC.destinationLoc = self?.destinationloc
                mainVC.isFromHome = true
                if(value.trip_id != "" ) {
                    mainVC.trip_or_rider_id = value.trip_id
                } else {
                    mainVC.trip_or_rider_id = value.trip_rider_id
                }
                mainVC.type = strtype
                self?.navigationController?.pushViewController(mainVC, animated: true)
            } else {
                
                self?.showAlert(value.status, value.message)
            }
        }).disposed(by: rx.bag)
    }
    
    func getFromAddress(strtype : String,strno_of_kms : String) {
    
        let address = Address()
       address.type = "trip_from"
       address.lattitude = "\(currentloc.latitude)"
       address.longitude = "\(currentloc.longitude)"
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()


               let ceo: CLGeocoder = CLGeocoder()
               center.latitude = currentloc.latitude
               center.longitude = currentloc.longitude

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
                        self.fromAddress = address.toParams()
                        self.gettoAddress(strtype: strtype, strno_of_kms: strno_of_kms)


                     }
               })
       print("formattedAddress \(address.toParams())")
       if(address.toParams().count == 0) {
          self.showAlert("fail","Please enable your location service and retry")
       }
       
    }
    func gettoAddress(strtype : String,strno_of_kms : String)  {
        let address = Address()
       address.type = "trip_to"
       address.lattitude = "\(destinationloc.latitude)"
       address.longitude = "\(destinationloc.longitude)"
       var center : CLLocationCoordinate2D = CLLocationCoordinate2D()


                     let ceo: CLGeocoder = CLGeocoder()
                     center.latitude = destinationloc.latitude
                     center.longitude = destinationloc.longitude

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
                                self.toAddress = address.toParams()

                                self.addMapFeedsList(strtype: strtype)


                           }
                     })
       print("formattedAddress \(address.toParams())")
       if(address.toParams().count == 0) {
           self.showAlert("fail","Please enable your location service and retry")
       }
       
    }
    func getDitance() -> Double  {
        let coordinate₀ = CLLocation(latitude: currentloc.latitude, longitude: currentloc.longitude)
        let coordinate₁ = CLLocation(latitude: destinationloc.latitude, longitude: destinationloc.longitude)
        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        return distanceInMeters
    }
    
    func getDate(date : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "EEE,MMM dd"
        let date = dateFormatter.date(from:date)!
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let myStringafd = dateFormatter.string(from: date)
        return myStringafd
    }
    func setCurrentDate(date : Date) {
        let formatter = DateFormatter()
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd"
        formatter.dateFormat = "EEE,\nMMM dd"
        let result = formatter.string(from: date)
        bookingDate = formatter2.string(from: date)
        btnDate.setTitle(result, for: .normal)
    }
    func setCurrentTime() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm\na"
        let result = formatter.string(from: date)
        btnSelectTime.setTitle(result, for: .normal)
    }
    private func updateUI() {
        let coordinates = CLLocationCoordinate2D(latitude: UserDefaults.latitude!, longitude: UserDefaults.longitude!)
        currentloc = coordinates
        LocationManager.shared.locateFromCoordinates(coordinates, result: { result in
            switch result {
            case .failure(let error):
                debugPrint("An error has occurred: \(error)")
            case .success(let places):
                print("Found \(places.count) places!")
                for place in places {
                    self.currentloc = place.coordinates
                    self.lblCurrentLoc.text = place.formattedAddress
                    self.mapview.setCenter(self.currentloc, zoomLevel: 15, animated: false)
                    let annotation = MGLPointAnnotation()
                    annotation.coordinate = self.currentloc
                       self.mapview.addAnnotation(annotation)
                }
            }
        })
        
    }
    @IBAction func autocompleteClicked(_ sender: UIButton) {
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
            
    //        let gpaViewController = GooglePlacesAutocomplete(
    //          apiKey: "AIzaSyCGr6pxw8X2PueadLwk3OHDghab56-oKNQ",
    //          placeType: .Address
    //        )
    //
    //        gpaViewController.placeDelegate = self
    //
    //        present(gpaViewController, animated: true, completion: nil)
        }
        
    @IBAction func src_loc(_ sender: Any) {
        
    }
    @IBAction func backbtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "week_days", for: indexPath as IndexPath) as! WeekDaysCollectionViewCell
        cell.week_day_txt.text = weekDays[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if(!daysarray.contains(weekDays[indexPath.row])) {
            cell?.backgroundColor = UIColor.white
            daysarray.append(weekDays[indexPath.row])
        } else {
            cell?.backgroundColor = .clear
            daysarray.remove(at: indexPath.row)
        }
        print("daysarray \(daysarray)")
    }
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = 27 * 7
        let totalSpacingWidth = 0

        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)

    }
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
        setCurrentDate(date: date as Date)
    }
    func WWCalendarTimeSelectorShouldSelectDate(_ selector: WWCalendarTimeSelector, date: Date) -> Bool {
        if date.timeIntervalSinceNow.isLess(than: 0) {
            return false
        } else {
            return true
        }
    }
    func setupChooseDropDown() {
        chooseDropDown.anchorView = btnseat
        chooseDropDown.frame.size.width = 40
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseDropDown.bottomOffset = CGPoint(x: 0, y: btnseat.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDropDown.dataSource = [
            "01",
            "02",
            "03",
            "04",
            "05",
            "06",
            "07"
        ]
        
        // Action triggered on selection
        chooseDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnseat.setTitle("\(item)\nseats", for: .normal)
        }
    }
}
extension BookingViewController: GooglePlacesAutocompleteDelegate {
  func placeSelected(place: Place) {
    print(place.description)
  }

  func placeViewClosed() {
    dismiss(animated: true, completion: nil)
  }
}

extension BookingViewController: GMSAutocompleteViewControllerDelegate {
    
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
            self.lblCurrentLoc.text = place.formattedAddress!
            self.currentloc = place.coordinate
        } else {
            self.lblDestinationLoc.text = place.formattedAddress!
            self.destinationloc = place.coordinate
        }
        self.mapview.setCenter(self.currentloc, zoomLevel: 19, animated: false)
        let annotation = MGLPointAnnotation()
        annotation.coordinate = self.currentloc
           self.mapview.addAnnotation(annotation)
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
