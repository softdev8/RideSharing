//
//  String.swift
//
//  Created by Perpetio Kovalsky on 3/14/17.
//  Copyright © 2017 perpet.io. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String, message : String?, cancelTapped: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: cancelTapped)
        alertController.addAction(OKAction)

        present(alertController, animated: true, completion: nil)
    }
}
