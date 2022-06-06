//
//  ViewController+CommonFunctions.swift
//  MOSAIC LIFE Rev2
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String = "",
                   message: String,
                   buttonTitle: String = "OK",
                   buttonAction: @escaping (() -> Void) = {}) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: buttonTitle, style: .default) { _ in buttonAction() }
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func getAlertController(title: String = "",
                    message: String = "",
                    fields: Int,
                    placeHolder: [String]
                    ) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if fields >= 1 && placeHolder.count == fields {
            for i in 0..<fields {
                alertController.addTextField { (testField: UITextField) -> Void in
                    testField.placeholder = placeHolder[i]
                }
            }
        }
        
        return alertController
    }
}
