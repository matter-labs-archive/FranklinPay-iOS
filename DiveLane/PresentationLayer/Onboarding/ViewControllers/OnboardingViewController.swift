//
//  OnboardingViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    private let userDefaults = UserDefaultKeys()

    var pageViewController: UIPageViewController!
    let nextBtn = UIButton(frame: CGRect(x: 0, y: 0, width: Constants.buttons.widths.onboarding, height: Constants.buttons.heights.onboarding))
    let skipBtn = UIButton(frame: CGRect(x: 0, y: 0, width: Constants.buttons.widths.onboarding, height: Constants.buttons.heights.onboarding))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = Colors.firstMain
        createPages()
    }

    func createPages() {

        let pc = UIPageControl.appearance()
        pc.pageIndicatorTintColor = Colors.active
        pc.currentPageIndicatorTintColor = Colors.secondMain
        pc.backgroundColor = Colors.firstMain

        self.pageViewController = UIPageViewController(transitionStyle: .scroll,
                navigationOrientation: .horizontal,
                options: nil)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: 0)],
                direction: .forward,
                animated: true,
                completion: nil)
        self.addChild(self.pageViewController)

        self.nextBtn.addTarget(self,
                action: #selector(onboardingAction(sender:)),
                for: .touchUpInside)
        self.nextBtn.setTitle("NEXT", for: .normal)
        self.nextBtn.backgroundColor = Colors.firstMain
        self.nextBtn.setTitleColor(Colors.secondMain, for: .normal)
        self.nextBtn.layer.cornerRadius = Constants.buttons.heights.onboarding / 2

        self.skipBtn.addTarget(self,
                               action: #selector(skipAction(sender:)),
                               for: .touchUpInside)
        self.nextBtn.setTitle("SKIP", for: .normal)
        self.nextBtn.backgroundColor = Colors.secondMain
        self.nextBtn.setTitleColor(Colors.active, for: .normal)
        self.nextBtn.layer.cornerRadius = Constants.buttons.heights.onboarding / 2

        let views = [
            "pg": self.pageViewController.view,
            "next": nextBtn,
            "skip": skipBtn
        ]
        for (_, v) in views {
            v?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(v!)
        }

        NSLayoutConstraint.activate(
                [NSLayoutConstraint(
                                    item: self.nextBtn,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: self.view,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ] +
                [NSLayoutConstraint(
                                    item: self.skipBtn,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: self.view,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ] +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-[pg]-|",
                                               options: .alignAllCenterX,
                                               metrics: [:],
                                               views: views as [String : Any]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-[pg]-30-[next]-30-[skip]-105-|",
                                               options: .alignAllCenterX,
                                               metrics: [:],
                                               views: views as [String : Any])
        )

        self.pageViewController.didMove(toParent: self)
    }

    @objc func onboardingAction(sender: UIButton) {
        if let vc = pageViewController.viewControllers?.first as? OnboardingContentViewController {
            switch vc.pageIndex {
            case 2:
                goToPincode()
            default:
                let index = vc.pageIndex + 1
                changeOnboardingButtonStatus(for: index)
                self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: index)],
                        direction: .forward,
                        animated: true,
                        completion: nil)
            }
        }

    }

    func goToPincode() {
        userDefaults.setOnboardingPassed()
        let vc = AppController().createPincodeController()
        vc.view.backgroundColor = Colors.firstMain
        self.present(vc, animated: true, completion: nil)
    }

    @objc func skipAction(sender: UIButton) {
        goToPincode()
    }

    func viewControllerAtIndex(index: Int) -> OnboardingContentViewController {
        if (PAGES.count == 0) || (index >= PAGES.count) {
            return OnboardingContentViewController()
        }
        let vc = OnboardingContentViewController()
        vc.pageIndex = index
        return vc
    }

    func changeOnboardingButtonStatus(for page: Int) {
        switch page {
        case 2:
            //self.nextBtn.setTitle("LETS GO!", for: .normal)
            self.skipBtn.isHidden = true
        default:
            self.skipBtn.isHidden = false
            //self.nextBtn.setTitle("NEXT", for: .normal)
        }
    }

}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as? OnboardingContentViewController)!
        var index = vc.pageIndex as Int
        if index == 0 || index == NSNotFound {
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index: index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as? OnboardingContentViewController)!
        var index = vc.pageIndex as Int
        if index == NSNotFound {
            return nil
        }
        index += 1
        if index == PAGES.count {
            return nil
        }
        return self.viewControllerAtIndex(index: index)
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let vc = pageViewController.viewControllers?.first as? OnboardingContentViewController else {
            return 0
        }
        //changeOnboardingButtonTitle(for: vc.pageIndex)
        return vc.pageIndex

    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return PAGES.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = pageViewController.viewControllers?.first as? OnboardingContentViewController {
            changeOnboardingButtonStatus(for: vc.pageIndex)
        }
    }

}
