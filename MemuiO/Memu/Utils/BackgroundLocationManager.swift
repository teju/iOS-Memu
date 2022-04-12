import Foundation
import CoreLocation
import UIKit

class BackgroundLocationManager :NSObject, CLLocationManagerDelegate {

    static let instance = BackgroundLocationManager()
    static let BACKGROUND_TIMER = 150.0 // restart location manager every 150 seconds
    static let UPDATE_SERVER_INTERVAL = 60 * 60 // 1 hour - once every 1 hour send location to server

    let locationManager = CLLocationManager()
    var timer:Timer?
    var currentBgTaskId : UIBackgroundTaskIdentifier?
    var lastLocationDate : NSDate = NSDate()

    private override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.activityType = .other;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        if #available(iOS 9, *){
            locationManager.allowsBackgroundLocationUpdates = true
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func applicationEnterBackground(){
        print("applicationEnterBackground")
        start()
    }

    func start(){
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            if #available(iOS 9, *){
               locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        } else {
                locationManager.requestAlwaysAuthorization()
        }
    }
    @objc func restart (){
        timer?.invalidate()
        timer = nil
        start()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.restricted: break
            //log("Restricted Access to location")
        case CLAuthorizationStatus.denied: break
            //log("User denied access to location")
        case CLAuthorizationStatus.notDetermined: break
            //log("Status not determined")
        default:
            //log("startUpdatintLocation")
            if #available(iOS 9, *){
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        }
    }
   
    func locationManager(_ _manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Background didUpdateLocations \(locations.last!) locationstimestamp \(locations.last!.timestamp)")
        if(timer==nil){
            // The locations array is sorted in chronologically ascending order, so the
            // last element is the most recent
            guard locations.last != nil else {return}

            beginNewBackgroundTask()
            locationManager.stopUpdatingLocation()
            
            sendLocationToServer(location: locations.last!)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         beginNewBackgroundTask()
         locationManager.stopUpdatingLocation()
    }
    

    func isItTime(now:NSDate) -> Bool {
        let timePast = now.timeIntervalSince(lastLocationDate as Date)
        let intervalExceeded = Int(timePast) > BackgroundLocationManager.UPDATE_SERVER_INTERVAL
        return intervalExceeded;
    }

    func sendLocationToServer(location:CLLocation){
        let address = Address()
        address.type = "current_location"
        address.lattitude = "\(location.coordinate.latitude)"
        address.longitude = "\(location.coordinate.longitude)"
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()


        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = location.coordinate.latitude
        center.longitude = location.coordinate.longitude

        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                if(placemarks == nil) {
                    return
                }
                let pm = placemarks! as [CLPlacemark]
                var addressString = ""
                print("CLPlacemark \(pm)")
                if pm.count > 0 {
                    let pm = placemarks![0]
                    
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                        address.location =  pm.subLocality!

                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "

                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                        address.country =  pm.country!

                    }
                    if pm.subAdministrativeArea != nil {
                       addressString = addressString + pm.subAdministrativeArea! + " "
                       address.city =  pm.subAdministrativeArea!
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                        address.pincode =  pm.postalCode!

                    }
                       address.formattedAddress = addressString
                 
                    self.updateLocation(address :address)


              }
        })
    }
    func updateLocation(address:Address) {
        RestDataSource.currentVehicleLocation(address)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success" {
               print("updateLocation success")
            } else {
                print("updateLocation failed")

            }
        }).disposed(by: rx.bag)
    }
    func beginNewBackgroundTask(){
        var previousTaskId = currentBgTaskId;
        currentBgTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            print("beginBackgroundTaskWithExpirationHandler")
        })
        if let taskId = previousTaskId{
            UIApplication.shared.endBackgroundTask(taskId)
            previousTaskId = UIBackgroundTaskIdentifier.invalid
        }

        timer = Timer.scheduledTimer(timeInterval: BackgroundLocationManager.BACKGROUND_TIMER, target: self, selector: #selector(self.restart),userInfo: nil, repeats: false)
    }
}
