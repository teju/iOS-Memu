//
//  CustomViewController.swift
//  Memu
//
//  Created by Tejaswini N on 15/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import Mapbox
import CoreLocation
import AVFoundation
import MapboxDirections
import Turf
import SwiftLocation
import CoreLocation
import SDWebImage

class CustomViewController: UIViewController, MGLMapViewDelegate {
    var destination: MGLPointAnnotation!
    let directions = Directions.shared
    var navigationService: NavigationService!
    var simulateLocation = false

    var userRoute: Route?
    var user: UserInfo!
    var feeds = [MapFeeds]()
    var trip_id = ""
    @IBOutlet weak var distance_time: UILabel!
    @IBOutlet weak var time_remaining: UILabel!
    var userRouteOptions: RouteOptions?

    @IBOutlet weak var btnEndTrip: UIButton!
    // Start voice instructions
    var voiceController: MapboxVoiceController!
    
    var stepsViewController: StepsViewController?

    // Preview index of step, this will be nil if we are not previewing an instruction
    var previewStepIndex: Int?
    
    // View that is placed over the instructions banner while we are previewing
    var previewInstructionsView: StepInstructionsView?
    
    @IBAction func map_feeds(_ sender: Any) {
        
    }
    @IBAction func recenture(_ sender: Any) {
         mapView.recenterMap()
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet var mapView: NavigationMapView!
   // @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var instructionsBannerView: InstructionsBannerView!
    
    lazy var feedbackViewController: FeedbackViewController = {
        return FeedbackViewController(eventsManager: navigationService.eventsManager)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let locationManager = simulateLocation ? SimulatedLocationManager(route: userRoute!) : NavigationLocationManager()
        print("NavigationLocationManager \(locationManager)")
        navigationService = MapboxNavigationService(route: userRoute!, routeOptions: userRouteOptions!, locationSource: locationManager, simulating: .never)
        
        voiceController = MapboxVoiceController(navigationService: navigationService)
        
        mapView.compassView.isHidden = false
        mapView.logoView.isHidden = true
        instructionsBannerView.isHidden = true
        bottomView.isHidden = true

        mapView.subviews[0].isHidden = false
        mapView.attributionButton.isHidden = true
        
        instructionsBannerView.delegate = self
        instructionsBannerView.swipeable = true
        
        // Add listeners for progress updates
        resumeNotifications()
        user = UserInfo()

        // Start navigation
        navigationService.start()
        self.mapView.delegate = self
        // Center map on user
        mapView.recenterMap()
        time_remaining.textColor = UIColor.systemGreen
        if(trip_id != "") {
            startTrip()
             btnEndTrip.isHidden = false
        } else {
            btnEndTrip.isHidden = true
        }
        
    }
    
    @IBAction func endTripAction(_ sender: Any) {
        endTrip(no_of_kms: distance_time.text!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // This applies a default style to the top banner.
        CustomDayStyle().apply()
        updateUI()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        navigationService.stop()
    }
    deinit {
        suspendNotifications()
    }
    func updateUI() {
        let coordinates = CLLocationCoordinate2D(latitude: UserDefaults.latitude!, longitude: UserDefaults.longitude!)
        LocationManager.shared.locateFromCoordinates(coordinates, result: { result in
            switch result {
            case .failure(let error):
                debugPrint("An error has occurred: \(error)")
            case .success(let places):
                print("Found \(places.count) places!")
                for place in places {
                    let address = Address()
                    address.type = "Home"
                    address.lattitude = "\(coordinates.latitude)"
                    address.longitude = "\(coordinates.longitude)"
                    address.formattedAddress = place.formattedAddress ?? ""
                     self.user.address.append(address)
                    print("formattedAddress \(address.toParams())")
                    self.getMapFeedsList(address: address.toParams())
                }
            }
        })
    }
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        let coordinates = CLLocationCoordinate2D(latitude: UserDefaults.latitude!, longitude: UserDefaults.longitude!)
        mapView.setCenter(coordinates, zoomLevel: 15, animated: false)
    }
    @IBAction func mapfeeds(_ sender: Any) {
        let popvc = UIStoryboard(name: "NavigationController", bundle: nil).instantiateViewController(withIdentifier: "MapFeedsPopUpController") as! MapFeedsPopUpController

        self.addChild(popvc)

        popvc.view.frame = self.view.frame

        self.view.addSubview(popvc.view)

        popvc.didMove(toParent: self)
    }
    func getMapFeedsList(address : [String: Any]) {
        RestDataSource.mapFeedsList(address: address)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success" {
                self?.feeds = value.feeds
                self?.addMArkers(feeds: value.feeds)
            } else {
                self?.showAlert(value.status, value.message)
            }
        }).disposed(by: rx.bag)
    }
    func startTrip() {
        RestDataSource.startTrip(trip_id: trip_id)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.showAlert(value.status, value.message)
            }).disposed(by: rx.bag)
    }
    func endTrip(no_of_kms : String) {
        RestDataSource.endtTrip(trip_id: trip_id, no_of_kms: no_of_kms)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                self?.showAlert(value.status, value.message)
            }).disposed(by: rx.bag)
    }
    func addMArkers(feeds : [MapFeeds]) {
 
        for feed in feeds {
            let point = CustomPointAnnotation(coordinate: CLLocationCoordinate2DMake((feed.lattitude as NSString).doubleValue, (feed.longitude as NSString).doubleValue),
                title: "Custom Point Annotation",
                subtitle: nil)
            // Set the custom `image` and `reuseIdentifier` properties, later used in the `mapView:imageForAnnotation:` delegate method.
            point.reuseIdentifier = feed.feed_name
           
            let imageURL = URL(string: feed.logo)
            let task = URLSession.shared.dataTask(with: imageURL!) { data, response, error in

                guard let data = data, error == nil else { return }

                DispatchQueue.main.async() {
                    let image : UIImage = UIImage(data: data)!
                    point.image = image
                    point.image = self.resizeImage(image: point.image!, targetSize: CGSize(width: 40.0, height: 40.0))
                    self.mapView.addAnnotation(point)
                    print("profile_picture data \(data) error \(error)")
                }
            }

            task.resume()
            //profile_picture.sd_setImage(with: imageURL)
            
            
//            let annotation = MGLPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude: (feed.lattitude as NSString).doubleValue, longitude: (feed.longitude as NSString).doubleValue)
//            mapView.addAnnotation(annotation)
        }
        
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
  
    func resumeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(progressDidChange(_ :)), name: .routeControllerProgressDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rerouted(_:)), name: .routeControllerDidReroute, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateInstructionsBanner(notification:)), name: .routeControllerDidPassVisualInstructionPoint, object: navigationService.router)
    }

    func suspendNotifications() {
        NotificationCenter.default.removeObserver(self, name: .routeControllerProgressDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .routeControllerWillReroute, object: nil)
        NotificationCenter.default.removeObserver(self, name: .routeControllerDidPassVisualInstructionPoint, object: nil)
    }

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        self.mapView.show([navigationService.route])
        let point = MGLPointAnnotation()
           
        style.setImage(UIImage(named: "nps-restrooms")!, forName: "restrooms")
        style.setImage(UIImage(named: "nps-trailhead")!, forName: "trailhead")
        style.setImage(UIImage(named: "nps-picnic-area")!, forName: "picnic-area")
         
        // Access a vector tileset that contains places of interest at Yosemite National Park. This tileset was created by uploading NPS shapefiles to Mapbox Studio.
        let url = URL(string: "mapbox://examples.ciuz0vpc")!
         
        // Add the vector tileset to the map's style.
        let source = MGLVectorTileSource(identifier: "yosemite-pois", configurationURL: url)
        style.addSource(source)
         
        // Create a symbol style layer and access the layer containin
        let layer = MGLSymbolStyleLayer(identifier: "yosemite-pois", source: source)
         
        // Access the layer that contains the POI data. The source layer identifier is a unique identifier for a layer within a vector tile source.
        layer.sourceLayerIdentifier = "Yosemite_POI-38jhes"
         
        // Create a stops dictionary with keys that are possible values for 'POITYPE', paired with icon images that will represent those features.
        let poiIcons = ["Picnic Area": "picnic-area", "Restroom": "restrooms", "Trailhead": "trailhead"]
         
        // Use the stops dictionary to assign an icon based on the "POITYPE" for each feature.
        layer.iconImageName = NSExpression(format: "FUNCTION(%@, 'valueForKeyPath:', POITYPE)", poiIcons)
         
        style.addLayer(layer)
    }

    // Notifications sent on all location updates
    @objc func progressDidChange(_ notification: NSNotification) {
        // do not update if we are previewing instruction steps
        guard previewInstructionsView == nil else { return }
        instructionsBannerView.isHidden = false
        bottomView.isHidden = false

        let routeProgress = notification.userInfo![RouteController.NotificationUserInfoKey.routeProgressKey] as! RouteProgress
        let location = notification.userInfo![RouteController.NotificationUserInfoKey.locationKey] as! CLLocation
        
        // Add maneuver arrow
        if routeProgress.currentLegProgress.followOnStep != nil {
            mapView.addArrow(route: routeProgress.route, legIndex: routeProgress.legIndex, stepIndex: routeProgress.currentLegProgress.stepIndex + 1)
        } else {
            mapView.removeArrow()
        }
        
        // Update the top banner with progress updates
        instructionsBannerView.updateDistance(for: routeProgress.currentLegProgress.currentStepProgress)
        instructionsBannerView.isHidden = false
        var suffix = "hr"
        let durationRemaining = routeProgress.durationRemaining
        let dist = routeProgress.distanceRemaining / 1000
        var time_taken = durationRemaining  / 3600
        if(time_taken <  1) {
            suffix = "min"
            time_taken = durationRemaining  / 60
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let current_time = formatter.string(from: date)
        time_remaining.text =  String(format:"%.2f \(suffix)", time_taken)
        distance_time.text = "\(current_time) ,"+String(format:"%.2f km", dist)
        // Update the user puck
        mapView.updateCourseTracking(location: location, animated: true)
        if routeProgress.currentLegProgress.userHasArrivedAtWaypoint {
            navigationService.stop()
            if(trip_id != "") {
             endTrip(no_of_kms: distance_time.text!)
            }
        }
    }
    
    @objc func updateInstructionsBanner(notification: NSNotification) {
        guard let routeProgress = notification.userInfo?[RouteController.NotificationUserInfoKey.routeProgressKey] as? RouteProgress else { return }
        instructionsBannerView.update(for: routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction)
    }

    // Fired when the user is no longer on the route.
    // Update the route on the map.
    @objc func rerouted(_ notification: NSNotification) {
        self.mapView.show([navigationService.route])
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recenterMap(_ sender: Any) {
        mapView.recenterMap()
    }
    
    @IBAction func showFeedback(_ sender: Any) {
        present(feedbackViewController, animated: true, completion: nil)
    }
    
    func toggleStepsList() {
        // remove the preview banner while viewing the steps list
        removePreviewInstruction()

        if let controller = stepsViewController {
            controller.dismiss()
            stepsViewController = nil
        } else {
            guard let service = navigationService else { return }
            
            let controller = StepsViewController(routeProgress: service.routeProgress)
            controller.delegate = self
            addChild(controller)
            view.addSubview(controller.view)
            
            controller.view.topAnchor.constraint(equalTo: instructionsBannerView.bottomAnchor).isActive = true
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

            controller.didMove(toParent: self)
            view.layoutIfNeeded()
            stepsViewController = controller
            return
        }
    }
    
    func addPreviewInstructions(step: RouteStep) {
        let route = navigationService.route
        
        // find the leg that contains the step, legIndex, and stepIndex
        guard let leg = route.legs.first(where: { $0.steps.contains(step) }),
            let legIndex = route.legs.firstIndex(of: leg),
            let stepIndex = leg.steps.firstIndex(of: step) else {
            return
        }
        
        // find the upcoming manuever step, and update instructions banner to show preview
        guard stepIndex + 1 < leg.steps.endIndex else { return }
        let maneuverStep = leg.steps[stepIndex + 1]
        updatePreviewBannerWith(step: step, maneuverStep: maneuverStep)
        
        // stop tracking user, and move camera to step location
        mapView.tracksUserCourse = false
        mapView.userTrackingMode = .none
        mapView.enableFrameByFrameCourseViewTracking(for: 1)
        mapView.setCenter(maneuverStep.maneuverLocation, zoomLevel: mapView.zoomLevel, direction: maneuverStep.initialHeading!, animated: true, completionHandler: nil)
        
        // add arrow to map for preview instruction
        mapView.addArrow(route: route, legIndex: legIndex, stepIndex: stepIndex + 1)
    }
    
    func updatePreviewBannerWith(step: RouteStep, maneuverStep: RouteStep) {
        // remove preview banner if it exists
        removePreviewInstruction()
        
        // grab the last instruction for step
        guard let instructions = step.instructionsDisplayedAlongStep?.last else { return }
        
        // create a StepInstructionsView and display that over the current instructions banner
        let previewInstructionsView = StepInstructionsView(frame: instructionsBannerView.frame)
        previewInstructionsView.delegate = self
        previewInstructionsView.swipeable = true
        previewInstructionsView.backgroundColor = instructionsBannerView.backgroundColor
        view.addSubview(previewInstructionsView)
//
        // update instructions banner to show all information about this step
       previewInstructionsView.updateDistance(for: RouteStepProgress(step: step))
       previewInstructionsView.update(for: instructions)
        
        self.previewInstructionsView = previewInstructionsView
    }
    
    func removePreviewInstruction() {
        guard let view = previewInstructionsView else { return }
        view.removeFromSuperview()
        
        // reclaim the delegate, from the preview banner
        instructionsBannerView.delegate = self
        
        // nil out both the view and index
        previewInstructionsView = nil
        previewStepIndex = nil
    }
}

extension CustomViewController: InstructionsBannerViewDelegate {
    func didTapInstructionsBanner(_ sender: BaseInstructionsBannerView) {
        toggleStepsList()
    }
    
    func didSwipeInstructionsBanner(_ sender: BaseInstructionsBannerView, swipeDirection direction: UISwipeGestureRecognizer.Direction) {
        if direction == .down {
            toggleStepsList()
            return
        }
        
        // preventing swiping if the steps list is visible
        guard stepsViewController == nil else { return }
        
        // Make sure that we actually have remaining steps left
        guard let remainingSteps = navigationService?.routeProgress.remainingSteps else { return }
        
        var previewIndex = -1
        var previewStep: RouteStep?
        
        if direction == .left {
            // get the next step from our current preview step index
            if let currentPreviewIndex = previewStepIndex {
                previewIndex = currentPreviewIndex + 1
            } else {
                previewIndex = 0
            }
            
            // index is out of bounds, we have no step to show
            guard previewIndex < remainingSteps.count else { return }
            previewStep = remainingSteps[previewIndex]
        } else {
            // we are already at step 0, no need to show anything
            guard let currentPreviewIndex = previewStepIndex else { return }
            
            if currentPreviewIndex > 0 {
                previewIndex = currentPreviewIndex - 1
                previewStep = remainingSteps[previewIndex]
            } else {
                previewStep = navigationService.routeProgress.currentLegProgress.currentStep
                previewIndex = -1
            }
        }
        
        if let step = previewStep {
            addPreviewInstructions(step: step)
            previewStepIndex = previewIndex
        }
    }
}

extension CustomViewController: StepsViewControllerDelegate {
    func didDismissStepsViewController(_ viewController: StepsViewController) {
        viewController.dismiss { [weak self] in
            self?.stepsViewController = nil
        }
    }
    
    func stepsViewController(_ viewController: StepsViewController, didSelect legIndex: Int, stepIndex: Int, cell: StepTableViewCell) {
        viewController.dismiss { [weak self] in
            self?.stepsViewController = nil
        }
    }
}
class CustomDayStyle: DayStyle {
 
    private let backgroundColor = #colorLiteral(red: 0.06276176125, green: 0.6164312959, blue: 0.3432356119, alpha: 1)
    private let darkBackgroundColor = #colorLiteral(red: 0.0473754704, green: 0.4980872273, blue: 0.2575169504, alpha: 1)
    private let secondaryBackgroundColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
    private let blueColor = #colorLiteral(red: 0.26683864, green: 0.5903761983, blue: 1, alpha: 1)
    private let lightGrayColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    private let darkGrayColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let primaryLabelColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let secondaryLabelColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9)
     
    required init() {
        super.init()
        mapStyleURL = URL(string: "mapbox://styles/mapbox/satellite-streets-v9")!
        styleType = .day
    }
     
    override func apply() {
        super.apply()
        ArrivalTimeLabel.appearance().textColor = lightGrayColor
        BottomBannerView.appearance().backgroundColor = secondaryBackgroundColor
        Button.appearance().textColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        CancelButton.appearance().tintColor = lightGrayColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).unitTextColor = secondaryLabelColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).valueTextColor = primaryLabelColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).unitTextColor = lightGrayColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).valueTextColor = darkGrayColor
        DistanceRemainingLabel.appearance().textColor = lightGrayColor
        DismissButton.appearance().textColor = darkGrayColor
        FloatingButton.appearance().backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        FloatingButton.appearance().tintColor = blueColor
        InstructionsBannerView.appearance().backgroundColor = backgroundColor
        LanesView.appearance().backgroundColor = darkBackgroundColor
        LaneView.appearance().primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance().backgroundColor = backgroundColor
        ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).secondaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).primaryColor = darkGrayColor
        ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).secondaryColor = lightGrayColor
        MarkerView.appearance().pinColor = blueColor
        NextBannerView.appearance().backgroundColor = backgroundColor
        NextInstructionLabel.appearance().textColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        NavigationMapView.appearance().tintColor = blueColor
        NavigationMapView.appearance().routeCasingColor = #colorLiteral(red: 0.1968861222, green: 0.4148176908, blue: 0.8596113324, alpha: 1)
        NavigationMapView.appearance().trafficHeavyColor = #colorLiteral(red: 0.9995597005, green: 0, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficLowColor = blueColor
        NavigationMapView.appearance().trafficModerateColor = #colorLiteral(red: 1, green: 0.6184511781, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficSevereColor = #colorLiteral(red: 0.7458544374, green: 0.0006075350102, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficUnknownColor = blueColor
        PrimaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = primaryLabelColor
        PrimaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = darkGrayColor
        ResumeButton.appearance().backgroundColor = secondaryBackgroundColor
        ResumeButton.appearance().tintColor = blueColor
        SecondaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = secondaryLabelColor
        SecondaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = darkGrayColor
        TimeRemainingLabel.appearance().textColor = lightGrayColor
        TimeRemainingLabel.appearance().trafficLowColor = darkBackgroundColor
        TimeRemainingLabel.appearance().trafficUnknownColor = darkGrayColor
        WayNameLabel.appearance().normalTextColor = blueColor
        WayNameView.appearance().backgroundColor = secondaryBackgroundColor
    }
}
 
 
