

import UIKit
import Firebase
import FirebaseDatabase
import MapKit
import CoreLocation

class RequestVC: UITableViewController, CLLocationManagerDelegate {
    
    var prices = [String]()
    var locationManager = CLLocationManager()
    var sellerUserNames = [String]() {
        didSet {
        }
    }
    var requestLocations = [CLLocationCoordinate2D]() {
        didSet {
        }
    }
    
    func sortLocations() {
        for i in 0 ..< requestLocations.count
        {
            for j in i + 1 ..< requestLocations.count {
                if getDistance(location: requestLocations[i]) > getDistance(location: requestLocations[j])
                {
                    let temp = requestLocations[i]
                    let temp1 = sellerUserNames[i]
                    let temp2 = prices[i]
                    requestLocations[i] = requestLocations[j]
                    requestLocations[j] = temp
                    sellerUserNames[i] = sellerUserNames[j]
                    sellerUserNames[j] = temp1
                    prices[i] = prices[j]
                    prices[j] = temp2
                }
            }
        }
    }
    
    func getDistance(location: CLLocationCoordinate2D) -> Double
    {
        let currentLocation = locationManager.location?.coordinate
        if currentLocation == nil {
            return 0
        }
        
        let buyerLocation = CLLocation(latitude: (currentLocation?.latitude)!, longitude: (currentLocation?.longitude)!)
        let sellerLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let distance = buyerLocation.distance(from: sellerLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        let distanceInMiles = roundedDistance * 0.621
        let roundedDistanceInMiles = round(distanceInMiles * 1000) / 1000
        
        return roundedDistanceInMiles
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMain" {
            self.navigationController?.navigationBar.isHidden = true
        }
        else if segue.identifier == "showSpotLocation" {
            
            if let _destination = segue.destination as? SpotLocationVC {
                
                if let row = self.tableView.indexPathForSelectedRow?.row {
                    
                    let dist = getDistance(location: requestLocations[row])
                    
                    _destination.myLocation = (locationManager.location?.coordinate)!
                    _destination.requestLocation = requestLocations[row]
                    _destination.requestUsername = sellerUserNames[row]
                    _destination.price = prices[row];
                    _destination.distance = dist
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Sell_Request").observe(FIRDataEventType.childAdded, with: { (FIRDataSnapshot) in
            
            if let data = FIRDataSnapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if let lat = data["latitude"] as? Double {
                        if let long = data["longitude"] as? Double {
                            if let price = data["Price"] as? String {
                            
                            print("\(self.sellerUserNames) Location: Latitude: \(lat), Longitude: \(long)")
                            
                            self.sellerUserNames.append(name)
                            self.requestLocations.append(CLLocationCoordinate2D(latitude: lat, longitude: long))
                            self.prices.append(price)
                            
                            self.sortLocations()
                            self.tableView.reloadData()
                            
                            
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.sortLocations()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return sellerUserNames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let roundedDistanceInMiles = getDistance(location: requestLocations[indexPath.row])
        
        cell.textLabel?.text = "$" + prices[indexPath.row] + " - \(roundedDistanceInMiles) miles away"
        
        return cell
    }
}
