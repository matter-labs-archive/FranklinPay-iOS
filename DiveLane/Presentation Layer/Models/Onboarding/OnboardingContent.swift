//
//  OnboardingContent.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

struct OnboardingContentModel {
    var title: String
    var image: UIImage
}

let PAGES = [
    OnboardingContentModel(title: "Onboarding 1", image: UIImage(named: "onboarding1")!),
    OnboardingContentModel(title: "Onboarding 2", image: UIImage(named: "onboarding2")!),
    OnboardingContentModel(title: "Onboarding 3", image: UIImage(named: "onboarding3")!)
]
