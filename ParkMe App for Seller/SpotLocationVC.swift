
import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import MBProgressHUD
import SwiftLocation

class SpotLocationVC: UIViewController, MKMapViewDelegate {
    
    var myLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var requestLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var requestUsername = ""
    var price = ""
    var distance = 0.0

    var ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var purchaseSpotButton: UIButton!

    var didShowNearbyAlert = false

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = requestLocation
        let spotInfo = requestUsername + " - $" + price;
        
        annotation.title = spotInfo;
        
        mapView.addAnnotation(annotation)
        
    }
    
    func updateLocation() {
        Location.getLocation(accuracy: .city, frequency: .continuous, success: { (_, location) in
            print("A new update of location is available: \(location)")

            DBProvider.Instance.buyRequestRef.queryOrdered(byChild: "seller_name").queryEqual(toValue: self.requestUsername).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                let enumerator = snapshot.children
                while let buy_request = enumerator.nextObject() as? FIRDataSnapshot {
                    let data = buy_request.value as? NSDictionary
                    if let accepted = data?["accepted"] as? Bool {
                        if accepted == true {
                            buy_request.ref.child(Constants.LATITUDE).setValue(location.coordinate.latitude)
                            buy_request.ref.child(Constants.LONGITUDE).setValue(location.coordinate.longitude)
                        }
                    }
                }
            })

            let sourceLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let destinationLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)


            if sourceLocation.distance(from: destinationLocation) <= 4 && !self.didShowNearbyAlert {
                self.presentAlert(title: "Arrived at Parking Spot", message: "You have arrived at your location. Have a nice day!")
                self.didShowNearbyAlert = true
                
               //DBProvider.Instance.buyRequestRef.queryOrdered(byChild: "seller_name").queryEqual(toValue: self.requestUsername)
               //DBProvider.Instance.buyRequestRef.child(self.requestUsername).removeValue();
                
            }

            let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(sourceLocation.coordinate.latitude), longitude: CLLocationDegrees(sourceLocation.coordinate.longitude)), addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(destinationLocation.coordinate.latitude), longitude: CLLocationDegrees(destinationLocation.coordinate.longitude)), addressDictionary: nil)

            let request = MKDirectionsRequest()
            request.source = MKMapItem(placemark: sourcePlacemark)
            request.destination = MKMapItem(placemark: destinationPlacemark)
            request.transportType = .any
            request.requestsAlternateRoutes = true
            let directions = MKDirections(request: request)
            directions.calculate { [unowned self] response, error in
                self.mapView.removeOverlays(self.mapView.overlays)

                guard let route = response?.routes.first else {
                    return
                }

                self.mapView.add(route.polyline, level: .aboveRoads)
            }

        }) { (request, last, error) in
            request.cancel() // stop continous location monitoring on error
            print("Location monitoring failed due to an error \(error)")
        }


    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)

            renderer.strokeColor = .blue
            renderer.lineWidth = 5

            return renderer
        }

        return MKOverlayRenderer()
    }

    @IBAction func purchaseSpot(_ sender: Any) {
        
        let buyerName = user?.email
        
        if (buyerName != requestUsername){  // Make sure buyer is not purchasing their own spot
            
            let data: Dictionary<String, Any> = ["user_ID": user?.uid, "name": buyerName, "seller_name": requestUsername, "Price": price, "Distance": distance, Constants.LATITUDE: self.myLocation.latitude, Constants.LONGITUDE: self.myLocation.longitude];
            DBProvider.Instance.buyRequestRef.childByAutoId().setValue(data);
            
            let progressView = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressView.label.text = "Waiting for seller's response..."

            DBProvider.Instance.buyRequestRef.queryOrdered(byChild: "seller_name").queryEqual(toValue: self.requestUsername).observeSingleEvent(of: FIRDataEventType.childChanged) {
                (snapshot: FIRDataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data["name"] as? String {
                        if name == self.user?.email {
                            if let accepted = data["accepted"] as? Bool {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                                                
                                let alert = UIAlertController(title: accepted ? "Accepted" : "Rejected", message: accepted ? "Seller accepted your request" : "Seller canceled your request", preferredStyle: .alert);
                                let ok = UIAlertAction(title: "Ok", style: .default, handler: {(action: UIAlertAction) in
                                    if accepted == true {
                                        self.updateLocation()

                                        let buyerLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                                        
                                        CLGeocoder().reverseGeocodeLocation(buyerLocation, completionHandler: { (placemarks, error) in
                                            if let placemarks = placemarks {
                                                if placemarks.count > 0 {
                                                    let mKPlacemark = MKPlacemark(placemark: placemarks[0])
                                                    let mapItem = MKMapItem(placemark: mKPlacemark)
                                                    mapItem.name = self.requestUsername
                                                    
                                                    if self.didShowNearbyAlert == false {

                                                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                                    
                                                    mapItem.openInMaps(launchOptions: launchOptions)
                                                    
                                                    self.didShowNearbyAlert = true;
                                                        
                                                    }
                                                    
                                                }
                                            }
                                        })
                                    }
                                });
                                    
                                alert.addAction(ok);
                                self.present(alert, animated: true, completion: nil);
                            }
                        }
                    }
                }
            }
        }
    }
}




