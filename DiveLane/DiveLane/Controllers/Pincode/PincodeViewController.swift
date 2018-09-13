//
//  PincodeViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 12/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class PincodeViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var firstNum: UIImageView!
    @IBOutlet weak var secondNum: UIImageView!
    @IBOutlet weak var thirdNum: UIImageView!
    @IBOutlet weak var fourthNum: UIImageView!
    
    @IBOutlet weak var biometricsButton: UIButton!
    
    var numsIcons: [UIImageView]?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numsIcons = [firstNum, secondNum, thirdNum, fourthNum]
    }
    
    func changeNumsIcons(_ nums: Int) {
        switch nums {
        case 0:
            for i in 0...(numsIcons?.count)!-1 {
                self.numsIcons![i].image = UIImage(named: "white_line")
            }
        case 4:
            for i in 0...nums-1 {
                self.numsIcons![i].image = UIImage(named: "White_dot")
            }
        default:
            for i in 0...nums-1 {
                self.numsIcons![i].image = UIImage(named: "White_dot")
            }
            for i in nums...(numsIcons?.count)!-1 {
                self.numsIcons![i].image = UIImage(named: "white_line")
            }
        }
    }
    
    @IBAction func buttonTouchedDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)},
                       completion: nil)
    }
    
    @IBAction func buttonTouchCanceled(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05) {
            sender.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func buttonTouchDragInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)},
                       completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: PinCodeNumberButton) {
        let number = sender.currentTitle!
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform.identity
            }
        }
        
        numberPressedAction(number: number)
        
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform.identity
            }
        }
        
        deletePressedAction()
    }
    
    @IBAction func biometricsPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform.identity
            }
        }
        
        biometricsPressedAction()
    }
    
    func deletePressedAction() {
        
    }
    
    func numberPressedAction(number: String) {
        
    }
    
    func biometricsPressedAction() {
        
    }
}
