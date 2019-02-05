////
////  TokenInfoViewController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 02.10.2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//class TokenInfoViewController: UIViewController {
//
//    var interactor: Interactor?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//
//    @IBAction func close(sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
//        let percentThreshold: CGFloat = 0.3
//
//        let translation = sender.translation(in: view)
//        let verticalMovement = translation.y / view.bounds.height
//        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
//        let downwardMovementPercent = fminf(downwardMovement, 1.0)
//        let progress = CGFloat(downwardMovementPercent)
//
//        guard let interactor = interactor else { return }
//
//        switch sender.state {
//        case .began:
//            interactor.hasStarted = true
//            dismiss(animated: true, completion: nil)
//        case .changed:
//            interactor.shouldFinish = progress > percentThreshold
//            interactor.update(progress)
//        case .cancelled:
//            interactor.hasStarted = false
//            interactor.cancel()
//        case .ended:
//            interactor.hasStarted = false
//            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
//        default:
//            break
//        }
//    }
//
////    convenience init(interactor: Interactor) {
////        self.init()
////        self.interactor = interactor
////    }
//}
