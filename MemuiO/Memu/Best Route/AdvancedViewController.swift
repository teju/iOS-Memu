import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Mapbox
import SDWebImage

class AdvancedViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, NavigationMapViewDelegate, NavigationViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout  {
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var mapView: NavigationMapView!
    @IBOutlet weak var profile_img: UIImageView!
    var trip_or_rider_id = ""
    var type = ""
    var complted_list = ScheduledList()
    var status = ""

    var currentRoute: Route? {
        get {
            return routes?.first
        }
        set {
            guard let selected = newValue else { routes?.remove(at: 0); return }
            guard let routes = routes else { self.routes = [selected]; return }
            self.routes = [selected] + routes.filter { $0 != selected }
        }
    }
    var routes: [Route]? {
        didSet {
            guard let routes = routes, let current = routes.first else { mapView?.removeRoutes(); return }
            mapView?.show(routes)
            mapView?.showWaypoints(on: current)
        }
    }
    @IBOutlet weak var btnstart: UIButton!
    var startButton: UIButton?
    var locationManager = CLLocationManager()
    
    private typealias RouteRequestSuccess = (([Route]) -> Void)
    private typealias RouteRequestFailure = ((NSError) -> Void)
    var btn_bg = ["blue_btn", "yellow_btn", "pink_button"]
    var smilies = ["option_a", "option_b", "option_c"]
    var loader :LoadingView? = nil

    var currentLoc: CLLocationCoordinate2D! = nil
    var destinationLoc: CLLocationCoordinate2D! = nil
    var routeOptions: NavigationRouteOptions?
    var isFromHome = false
    var isFromRecurring = false
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loader = LoadingView(parentView: self.view)
        let imageURL = URL(string: UserDefaults.profile_picture ?? "")
        profile_img.sd_setImage(with: imageURL)
        collection_view.delegate =  self
        collection_view.dataSource = self
        let flow = collection_view.collectionViewLayout as! UICollectionViewFlowLayout
               print("updateLocationGMSPlace viewDidLoad \(self.currentLoc)")

        flow.sectionInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 10)
       
        flow.minimumInteritemSpacing = 0
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        print("AdvancedViewController \(currentLoc) destinationLoc \(destinationLoc)")
        //mapView = NavigationMapView(frame: view.bounds)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView?.userTrackingMode = .follow
        mapView?.delegate = self
        mapView?.navigationMapViewDelegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if(self.currentLoc != nil && self.destinationLoc != nil) {
                self.requestRoute(source: self.currentLoc, destination: self.destinationLoc)
            }
        }
     
        loader?.show()
       NotificationCenter.default.addObserver(self, selector: #selector(self.goBack(notification:)), name: Notification.Name("GOBACK"), object: nil)

    }
   
    @IBAction func start(_ sender: Any) {
        guard let route = self.currentRoute, let routeOptions = self.routeOptions else { return }
               // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
        let dist = (route.distance) / 1000

       let storyboard = UIStoryboard(name: "NavigationController", bundle: nil)
              let loginPage = storyboard.instantiateViewController(withIdentifier: "CustomViewController") as! CustomViewController
            loginPage.userRoute = route
            loginPage.no_of_kms = "\(dist)"
            loginPage.userRouteOptions = routeOptions
        loginPage.trip_id = self.trip_or_rider_id
        loginPage.status = self.status
        loginPage.tripType = self.type
        let alert = UIAlertController(title: "", message: "Memu World is designed for safe navigation. We strongly do not recommend using social alerts features of the app while your are driving (or) riding. Please take fellow passengers help for using Social Alerts features. For your safety and convenience, dock your phone while in Assistant driving mode.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                    self.navigationController?.pushViewController(loginPage, animated: true)
                case .cancel:
                    self.navigationController?.pushViewController(loginPage, animated: true)
                case .destructive:
                    self.navigationController?.pushViewController(loginPage, animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    @objc func goBack(notification: Notification) {
        self.navigationController?.popViewController(animated: true)
    }
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
          let annotation = MGLPointAnnotation()
        if(currentLoc != nil) {
            annotation.coordinate = CLLocationCoordinate2D(latitude: currentLoc.latitude, longitude: currentLoc.longitude)
            mapView.addAnnotation(annotation)
            mapView.setCenter(currentLoc, zoomLevel: 15, animated: false)
        }
    }
    //overriding layout lifecycle callback so we can style the start button
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton?.layer.cornerRadius = startButton!.bounds.midY
        startButton?.clipsToBounds = true
        startButton?.setNeedsDisplay()
        
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedButton(sender: UIButton) {
        
       
    }
    
//     @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        guard gesture.state == .ended else { return }
//
//        let spot = gesture.location(in: mapView)
//        guard let location = mapView?.convert(spot, toCoordinateFrom: mapView) else { return }
//
//        requestRoute(destination: location)
//    }

    func requestRoute(source : CLLocationCoordinate2D ,destination: CLLocationCoordinate2D) {
        let userWaypoint = Waypoint(coordinate: source)
        let destinationWaypoint = Waypoint(coordinate: destination)
        
        routeOptions = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])

        
        Directions.shared.calculate(routeOptions!) { [weak self] (session, result) in
        switch result {
            case .failure(let error):
                self?.loader?.terminate()
                self?.initPopUps()
                print("AdvancedViewController Directions error \(error.localizedDescription)")
            case .success(let response):
                self?.loader?.terminate()
                self?.initPopUps()
                guard let routes = response.routes, let strongSelf = self else {
                    return
                }
                
                print("AdvancedViewController Directions success \(response)")
                self?.routeOptions = self?.routeOptions
                self?.routes = routes
                self?.startButton?.isHidden = false
                self?.mapView?.show(routes)
                self?.mapView?.showWaypoints(on: strongSelf.currentRoute!)
                self?.collection_view.reloadData()
                

            }
        }
    }
    func initPopUps(){
        if(isFromHome) {
            btnstart?.isHidden = false
            let popvc = UIStoryboard(name: "NavigationController", bundle: nil).instantiateViewController(withIdentifier: "MatchingRidersViewController") as! MatchingRidersViewController
              popvc.trip_or_rider_id = trip_or_rider_id
              popvc.type = type
               self.addChild(popvc)
                
               popvc.view.frame = self.view.frame

               self.view.addSubview(popvc.view)

               popvc.didMove(toParent: self)
        } else if(isFromRecurring) {
            btnstart?.isHidden = true
            let popvc = UIStoryboard(name: "HistoryStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ReurringViewController") as! ReurringViewController
            popvc.complted_list = complted_list
               self.addChild(popvc)
                
               popvc.view.frame = self.view.frame

               self.view.addSubview(popvc.view)

               popvc.didMove(toParent: self)
        }

    }

    // Delegate method called when the user selects a route
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        print("routes response \(route.expectedTravelTime)")

        self.currentRoute = route
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        //Where elements_count is the count of all your items in that
        //Collection view...
        let cellCount = CGFloat(self.routes?.count ?? 0)

        //If the cell count is zero, there is no point in calculating anything.
        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing

            //20.00 was just extra spacing I wanted to add to my cell.
            let totalCellWidth = cellWidth*cellCount + 20.00 * (cellCount-1)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right

            if (totalCellWidth < contentWidth) {
                //If the number of cells that exists take up less room than the
                //collection view width... then there is an actual point to centering them.

                //Calculate the right amount of padding to center the cells.
                let padding = (contentWidth - totalCellWidth) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            } else {
                //Pretty much if the number of cells that exist take up
                //more room than the actual collectionView width, there is no
                // point in trying to center them. So we leave the default behavior.
                return UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
            }
        }
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.routes?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dist_view", for: indexPath as IndexPath) as! DistCollectionViewCell
        let smilyimage = UIImage(named: smilies[indexPath.row]) as UIImage?
        cell.smily_img.image = smilyimage
        if(indexPath.row == 0) {
            cell.btn_bg_.layer.borderColor = UIColor.blue.cgColor
        } else if(indexPath.row == 1) {
            cell.btn_bg_.layer.borderColor = UIColor.yellow.cgColor
        } else {
            cell.btn_bg_.layer.borderColor = UIColor.systemPink.cgColor
        }
        var suffix = "hr"
        let expectedTravelTime = self.routes?[indexPath.row].expectedTravelTime
        let dist = (self.routes?[indexPath.row].distance)! / 1000
        var time_taken = expectedTravelTime!  / 3600
        if(time_taken <  1) {
            suffix = "min"
            time_taken = expectedTravelTime!  / 60
        }
        cell.distance.text = String(format:"%.2f km", dist)
        cell.time_req.text =  String(format:"%.2f \(suffix)", time_taken)

        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        
        print("You selected cell #\(indexPath.item)!")
    }
}

