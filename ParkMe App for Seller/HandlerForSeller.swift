

import Foundation
import FirebaseDatabase

class ParkingHandlerSeller {
    
    private static let _instance = ParkingHandlerSeller();
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    static var Instance: ParkingHandlerSeller {
        return _instance;
    }
    
}

 
