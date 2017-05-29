
// Handler for people wanting to buy parking spots

import Foundation
import FirebaseDatabase

protocol ParkerController: class {
    func acceptSpot(lat: Double, long: Double, buyer: String, dist: Double, price: String);
}

class RequesterHandler {
    static let _instance = RequesterHandler();
    
    weak var delegate: ParkerController?;
    var customer = ""
    
    static var Instance: RequesterHandler {
        return _instance;
    }
    
    func listenToRequests(){
        
        DBProvider.Instance.buyRequestRef.observe(FIRDataEventType.childAdded)  {
            (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let sellerName = data["seller_name"] as? String {
                    if data["accepted"] == nil {
                        if sellerName == ParkingHandler.Instance.seller {
                            if let latitude = data[Constants.LATITUDE] as?
                                Double {
                                if let longitude = data[Constants.LONGITUDE] as?
                                    Double {
                                    if let price = data["Price"] {
                                        if let distance = data["Distance"] {
                                            self.delegate?.acceptSpot(lat: latitude, long: longitude, buyer: (data["name"] as? String)!, dist: distance as! Double, price: price as! String)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        DBProvider.Instance.buyRequestRef.observe(FIRDataEventType.childChanged)  {
            (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let sellerName = data["seller_name"] as? String {
                    if data["accepted"] == nil {
                        if sellerName == ParkingHandler.Instance.seller {
                            if let latitude = data[Constants.LATITUDE] as?
                                Double {
                                if let longitude = data[Constants.LONGITUDE] as?
                                    Double {
                                    if let price = data["Price"] {
                                        if let distance = data["Distance"] {
                                        self.delegate?.acceptSpot(lat: latitude, long: longitude, buyer: (data["name"] as? String)!, dist: distance as! Double, price: price as! String)
                                        
                                    }
                                }
                                
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func acceptedParkingSpot(lat: Double, long: Double){
        let data: Dictionary<String, Any> = [Constants.NAME: customer, Constants.LATITUDE: lat, Constants.LONGITUDE: long]
        DBProvider.Instance.requestAccepted.childByAutoId().setValue(data)

    }

}
