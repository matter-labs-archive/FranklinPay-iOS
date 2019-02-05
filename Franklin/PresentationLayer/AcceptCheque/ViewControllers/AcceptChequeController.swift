//
//  AcceptChequeController.swift
//  Franklin
//
//  Created by Anton Grigorev on 28/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class AcceptChequeController: BasicViewController, ModalViewDelegate {
    
    let appController = AppController()
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let cheque: PlasmaCode
    
    let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
    
    init(cheque: PlasmaCode) {
        self.cheque = cheque
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.topViewForModalAnimation.blurView()
        self.topViewForModalAnimation.alpha = 0
        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        self.topViewForModalAnimation.isUserInteractionEnabled = false
        self.view.addSubview(topViewForModalAnimation)
        
        self.titleLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.modalViewAppeared()
        let acceptChequeForm = AcceptChequeFormController(cheque: cheque)
        acceptChequeForm.delegate = self
        acceptChequeForm.modalPresentationStyle = .overCurrentContext
        acceptChequeForm.view.layer.speed = Constants.ModalView.animationSpeed
        self.present(acceptChequeForm, animated: true, completion: nil)
    }
    
    func modalViewBeenDismissed() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = 0
                self.titleLabel.alpha = 0
                self.goToApp()
            })
        }
    }
    
    func goToApp() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.Main.animationDuration) {
                self.view.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let tabViewController = self.appController.goToApp()
                    tabViewController.view.backgroundColor = Colors.background
                    let transition = CATransition()
                    transition.duration = Constants.Main.animationDuration
                    transition.type = CATransitionType.push
                    transition.subtype = CATransitionSubtype.fromRight
                    transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                    self.present(tabViewController, animated: false, completion: nil)
                })
            }
        }
    }
    
    func modalViewAppeared() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
                self.titleLabel.alpha = 1.0
            })
        }
    }

}
