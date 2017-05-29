

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    public let RIDER_SEGUE = "RiderVC"

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func LogIn(_ sender: Any) {
        
        if (EmailTextField.text != "" && PasswordTextField.text != "") {
        AuthProvider.Instance.login(withEmail: EmailTextField.text!, password: PasswordTextField.text!, loginHandler: { (message) in
            
            if (message != nil) {
                self.alertUser(title: "Problem with Authentication", message: message!);
            }
            else{
                ParkingHandler.Instance.seller = self.EmailTextField.text!;
                self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            });
        }
        else{
            alertUser(title: "Email and Password Required", message: "Please enter a valid email and password");
        }
        
    }
    
    @IBAction func SignUp(_ sender: Any) {
    
        if (EmailTextField.text != "" && PasswordTextField.text != ""){
            AuthProvider.Instance.signUp(withEmail: EmailTextField.text!, password: PasswordTextField.text!, loginHandler: { (message) in
                if (message != nil){
                    self.alertUser(title: "Problem with Account Registration", message: message!);
                }
                else{
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil);
                }
            });
        }
        else{
            alertUser(title: "Email and Password Required", message: "Please enter a valid email and password");
        }
    }
    
    
    private func alertUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }

}
