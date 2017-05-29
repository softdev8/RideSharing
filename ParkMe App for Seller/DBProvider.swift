


import Foundation
import FirebaseDatabase
import FirebaseAuth

class DBProvider {

    private static let _instance = DBProvider();
    static var Instance: DBProvider{
        return _instance;
    }
    
    let user = FIRAuth.auth()?.currentUser

    
    var dbRef: FIRDatabaseReference {
        return FIRDatabase.database().reference();
    }
    
    var sellerRef: FIRDatabaseReference {
        return dbRef.child(Constants.SELLER);
    }
    
    var customerRef: FIRDatabaseReference {
        return dbRef.child(Constants.CUSTOMER);
    }
    
    // seller ref
    
    var sellRequestRef: FIRDatabaseReference {
        return dbRef.child(Constants.SELL_REQUEST)
    }
    
    // buy request ref
    
    var buyRequestRef: FIRDatabaseReference {
        return dbRef.child(Constants.BUY_REQUEST)
    }
    
    // request accepted
    
    var requestAccepted: FIRDatabaseReference {
        return dbRef.child(Constants.PARK_ACCEPTED)
    }

    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isRequester: true];
        
        sellerRef.child(withID).child(Constants.DATA).setValue(data); // save requester to DB
        customerRef.child(withID).child(Constants.DATA).setValue(data); // save seller to DB
        
    }
    
} // class
