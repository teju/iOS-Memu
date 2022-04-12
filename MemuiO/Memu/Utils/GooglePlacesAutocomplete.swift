//
//  GooglePlacesAutocomplete.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 6/9/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import Alamofire

enum PlaceType {
  case All
  case Geocode
  case Address
  case Establishment
  case Regions
  case Cities

  var description : String {
    switch self {
    case .All: return ""
    case .Geocode: return "geocode"
    case .Address: return "address"
    case .Establishment: return "establishment"
    case .Regions: return "regions"
    case .Cities: return "cities"
    }
  }
}

struct Place {
  let id: String?
  let description: String?
}

protocol GooglePlacesAutocompleteDelegate {
  func placeSelected(place: Place)
  func placeViewClosed()
}

// MARK: - GooglePlacesAutocomplete
class GooglePlacesAutocomplete: UINavigationController {
  var gpaViewController: GooglePlacesAutocompleteContainer?

  var placeDelegate: GooglePlacesAutocompleteDelegate? {
    get { return gpaViewController?.delegate }
    set { gpaViewController?.delegate = newValue }
  }

  convenience init(apiKey: String, placeType: PlaceType = .All) {
    let gpaViewController = GooglePlacesAutocompleteContainer(
      apiKey: apiKey,
      placeType: placeType
    )

    self.init(rootViewController: gpaViewController)
    self.gpaViewController = gpaViewController

    let closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(close))

    gpaViewController.navigationItem.leftBarButtonItem = closeButton
    gpaViewController.navigationItem.title = "Enter Address"
  }

  @objc func close() {
    placeDelegate?.placeViewClosed()
  }
}

// MARK: - GooglePlaceSearchDisplayController
class GooglePlaceSearchDisplayController: UISearchDisplayController {
    override func setActive(_ visible: Bool, animated: Bool) {
        if isActive == visible { return }

        searchContentsController.navigationController?.isNavigationBarHidden = true
    super.setActive(visible, animated: animated)

        searchContentsController.navigationController?.isNavigationBarHidden = false

    if visible {
      searchBar.becomeFirstResponder()
    } else {
      searchBar.resignFirstResponder()
    }
  }
}

// MARK: - GooglePlacesAutocompleteContainer
class GooglePlacesAutocompleteContainer: UIViewController {
  var delegate: GooglePlacesAutocompleteDelegate?
  var apiKey: String?
  var places = [Place]()
  var placeType: PlaceType = .All

  convenience init(apiKey: String, placeType: PlaceType = .All) {
    self.init(nibName: "GooglePlacesAutocomplete", bundle: nil)
    self.apiKey = apiKey
    self.placeType = placeType
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let tv: UITableView? = searchDisplayController?.searchResultsTableView
    tv?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.searchDisplayController?.searchResultsTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) else {
            return UITableViewCell()
        }
        
        // Get the corresponding candy from our candies array
        let place = self.places[indexPath.row]
        
        // Configure the cell
        cell.textLabel?.text = place.description
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.placeSelected(place: self.places[indexPath.row])
    }
    
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchDisplayDelegate)
extension GooglePlacesAutocompleteContainer: UISearchDisplayDelegate {
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        getPlaces(searchString: searchString)
        return false
    }
    
    private func getPlaces(searchString: String) {
        SessionManager.default.request("https://maps.googleapis.com/maps/api/place/autocomplete/json", method: .get, parameters: [
            "input": searchString,
            "type": "(\(placeType.description))",
            "key": apiKey ?? ""
        ]).response { data in
            if let response = data as? NSDictionary {
                if let predictions = response["predictions"] as? Array<AnyObject> {
                    self.places = predictions.map { (prediction: AnyObject) -> Place in
                        return Place(
                            id: prediction["id"] as? String,
                            description: prediction["description"] as? String
                        )
                    }
                }
            }
            self.searchDisplayController?.searchResultsTableView.reloadData()
        }
    }
}

