//
//  OnboardingViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    var pageViewController: UIPageViewController!
    let onboardingBtn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.BackgroundColors.main

        createPages()
    }

    func createPages() {

        let pc = UIPageControl.appearance()
        pc.pageIndicatorTintColor = UIColor.lightGray
        pc.currentPageIndicatorTintColor = UIColor.black
        pc.backgroundColor = Colors.BackgroundColors.main

        self.pageViewController = UIPageViewController(transitionStyle: .scroll,
                navigationOrientation: .horizontal,
                options: nil)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: 0)],
                direction: .forward,
                animated: true,
                completion: nil)
        self.addChildViewController(self.pageViewController)

        self.onboardingBtn.addTarget(self,
                action: #selector(onboardingAction(sender:)),
                for: .touchUpInside)
        self.onboardingBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.onboardingBtn.setTitle("NEXT", for: .normal)

        let views = [
            "pg": self.pageViewController.view,
            "btn": onboardingBtn
        ]
        for (_, v) in views {
            v?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(v!)
        }

        NSLayoutConstraint.activate(
                [NSLayoutConstraint(
                        item: self.onboardingBtn,
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
                                views: views) +
                        NSLayoutConstraint.constraints(withVisualFormat: "V:|-[pg]-[btn]-50-|",
                                options: .alignAllCenterX,
                                metrics: [:],
                                views: views)
        )

        self.pageViewController.didMove(toParentViewController: self)
    }

    @objc func onboardingAction(sender: UIButton) {
        if let vc = pageViewController.viewControllers?.first as? OnboardingContentViewController {
            switch vc.pageIndex {
            case 2:
                UserDefaults.standard.set(true, forKey: "isOnboardingPassed")
                let navViewController = addWallet()
                navViewController.view.backgroundColor = UIColor.white
                self.present(navViewController, animated: true, completion: nil)
            default:
                self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: vc.pageIndex + 1)],
                        direction: .forward,
                        animated: true,
                        completion: nil)
            }
        }

    }

    func viewControllerAtIndex(index: Int) -> OnboardingContentViewController {
        if (PAGES.count == 0) || (index >= PAGES.count) {
            return OnboardingContentViewController()
        }
        let vc = OnboardingContentViewController()
        vc.pageIndex = index
        return vc
    }

    func changeOnboardingButtonTitle(for page: Int) {
        switch page {
        case 2:
            self.onboardingBtn.setTitle("LETS GO!", for: .normal)
        default:
            self.onboardingBtn.setTitle("NEXT", for: .normal)
        }
    }

}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as? OnboardingContentViewController)!
        var index = vc.pageIndex as Int
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index: index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as? OnboardingContentViewController)!
        var index = vc.pageIndex as Int
        if (index == NSNotFound) {
            return nil
        }
        index += 1
        if (index == PAGES.count) {
            return nil
        }
        return self.viewControllerAtIndex(index: index)
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let vc = pageViewController.viewControllers?.first as? OnboardingContentViewController else {
            return 0
        }
        changeOnboardingButtonTitle(for: vc.pageIndex)
        return vc.pageIndex

    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return PAGES.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let vc = pageViewController.viewControllers?.first as? OnboardingContentViewController {
            changeOnboardingButtonTitle(for: vc.pageIndex)
        }
    }

}
