//
//  Alerts.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

public struct Alerts {
    public func showErrorAlert(for viewController: UIViewController, error: Error?, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            var text: String?
            if let error = error {
                text = error.localizedDescription
            }
            let alert = UIAlertController(title: "Error", message: text ?? error?.localizedDescription, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                completion?()
            }
            alert.addAction(cancelAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showErrorAlert(for viewController: UIViewController, error: String, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                completion?()
            }
            alert.addAction(cancelAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showSuccessAlert(for viewController: UIViewController, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (_) in
                completion?()
            }
            alert.addAction(cancelAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showSuccessAlert(for viewController: UIViewController, with text: String?, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: text, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (_) in
                completion?()
            }
            alert.addAction(cancelAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showAccessAlert(for viewController: UIViewController, with text: String?, completion: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: text ?? "Yes?", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                completion?(true)
            }
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in
                completion?(false)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
