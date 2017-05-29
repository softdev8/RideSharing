


import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct loginErrorCode{

    static let INVALID_EMAIL = "Invalid email address. Please provide a real email address";
    static let WRONG_PASSWORD = "Incorrect password. Please enter correct password";
    static let PROBLEM_CONNECTING = "Problem connecting. Please try again later";
    static let USER_NOT_FOUND = "User not found. Please re-enter username";
    static let EMAIL_IN_USE = "Email already in use. Please use another email";
    static let WEAK_PASSWORD = "Password is too weak. Please provide a stronger password";

}

class AuthProvider {

    private static let _instance = AuthProvider();
    
    static var Instance: AuthProvider{
    
        return _instance;
    
    }
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?){
    
        FIRAuth.auth()?.signIn(withEmail: withEmail, password: password, completion: { (user, error) in
        
            if (error != nil){
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
                } else{
                loginHandler?(nil);
            }
        });
    }
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?){
    
        FIRAuth.auth()?.createUser(withEmail: withEmail, password: password, completion: { (user, error) in
            if (error != nil){
                self.handleErrors(err: error as! NSError,
                    loginHandler: loginHandler);
            } else {
                if (user?.uid != nil){
                    
                    // store user to DB
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password);
                    
                    // login the user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler);
                    
                }
            }
        });
    
    }
    
    func logOut() -> Bool {
     
        if (FIRAuth.auth()?.currentUser != nil){
            do {
                try (FIRAuth.auth()?.signOut());
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?){
        if let errCode = FIRAuthErrorCode(rawValue: err.code){
            switch errCode {
                
            case .errorCodeWrongPassword:
                loginHandler?(loginErrorCode.WRONG_PASSWORD);
                break;
                
            case .errorCodeInvalidEmail:
                loginHandler?(loginErrorCode.INVALID_EMAIL);
                break;
                
            case .errorCodeUserNotFound:
                loginHandler?(loginErrorCode.USER_NOT_FOUND);
                break;
                
            case .errorCodeEmailAlreadyInUse:
                loginHandler?(loginErrorCode.EMAIL_IN_USE);
                break;
                
            case .errorCodeWeakPassword:
                loginHandler?(loginErrorCode.WEAK_PASSWORD);
                break;
                
            default:
                loginHandler?(loginErrorCode.PROBLEM_CONNECTING);
                break;
            }
        }
    }
}
