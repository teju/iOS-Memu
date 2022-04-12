//
//  BestRouteViewController.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/18/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import SwiftLocation

class BestRouteViewController: UIViewController {
    
    @IBOutlet weak var btnNExt: UIButton!
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var btnName: UIButton!
    
    @IBOutlet weak var lblCurrentLoc: UILabel!
    @IBOutlet weak var lblDestinationLoc: UILabel!
    
    private var tag = 0
    
    private var currentloc: CLLocationCoordinate2D! = nil
    private var destinationloc: CLLocationCoordinate2D! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage.gif(name: "next_button") as UIImage?
        btnNExt.setImage(image, for: .normal)
        // Do any additional setup after loading the view.
        updateUI()
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
                }
            }
        })
    }
    
    // Present the Autocomplete view controller when the button is pressed.
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        self.tag = sender.tag
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
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
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if currentloc != nil && destinationloc != nil {
            print("updateLocationGMSPlace \(self.currentloc)")

            let storyboard = UIStoryboard(name: "NavigationController", bundle: nil)
                   let mainVC = storyboard.instantiateViewController(withIdentifier: "AdvancedViewController") as! AdvancedViewController
                mainVC.currentLoc = self.currentloc
                mainVC.destinationLoc = self.destinationloc
                   
            self.navigationController?.pushViewController(mainVC, animated: true)
        } else {
            
        }
    }
}

extension BestRouteViewController: GooglePlacesAutocompleteDelegate {
  func placeSelected(place: Place) {
    print(place.description)
  }

  func placeViewClosed() {
    dismiss(animated: true, completion: nil)
  }
}

extension BestRouteViewController: GMSAutocompleteViewControllerDelegate {
    
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
