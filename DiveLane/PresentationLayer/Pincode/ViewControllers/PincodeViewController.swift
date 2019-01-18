//
//  PincodeViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 12/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class PincodeViewController: BasicViewController {

    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var firstNum: UIImageView!
    @IBOutlet weak var secondNum: UIImageView!
    @IBOutlet weak var thirdNum: UIImageView!
    @IBOutlet weak var fourthNum: UIImageView!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var biometricsButton: PinCodeNumberButton!
    @IBOutlet weak var deleteButton: PinCodeNumberButton!
    
    let animation = AnimationController()

    var numsIcons: [UIImageView]?

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        container.backgroundColor = Colors.firstMain
        biometricsButton.setImage(UIImage(named: "white_touch_id"), for: .normal)
        deleteButton.setImage(UIImage(named: "white_delete"), for: .normal)
        messageLabel.textColor = Colors.secondMain
        messageLabel.font = UIFont(name: Constants.boldFont,
                                   size: Constants.basicFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.basicFontSize)
        numsIcons = [firstNum, secondNum, thirdNum, fourthNum]
    }

    func changeNumsIcons(_ nums: Int) {
        switch nums {
        case 0:
            for i in 0...(numsIcons?.count)! - 1 {
                self.numsIcons![i].image = UIImage(named: "white_line")
            }
        case 4:
            for i in 0...nums - 1 {
                self.numsIcons![i].image = UIImage(named: "White_dot")
            }
        default:
            for i in 0...nums - 1 {
                self.numsIcons![i].image = UIImage(named: "White_dot")
            }
            for i in nums...(numsIcons?.count)! - 1 {
                self.numsIcons![i].image = UIImage(named: "white_line")
            }
        }
    }

    @IBAction func numButtonPressed(_ sender: PinCodeNumberButton) {
        let number = sender.currentTitle!

        animation.pressButtonCanceledAnimation(for: sender)

        numberPressedAction(number: number)

    }

    @IBAction func deletePressed(_ sender: UIButton) {
        animation.pressButtonCanceledAnimation(for: sender)

        deletePressedAction()
    }

    @IBAction func biometricsPressed(_ sender: UIButton) {
        animation.pressButtonCanceledAnimation(for: sender)

        biometricsPressedAction()
    }

    func deletePressedAction() {

    }

    func numberPressedAction(number: String) {

    }

    func biometricsPressedAction() {

    }
}
