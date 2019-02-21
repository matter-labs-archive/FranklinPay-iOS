//
//  ModalViewDelegate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

protocol ModalViewDelegate: class {
    func modalViewBeenDismissed(updateNeeded: Bool)
    func modalViewAppeared()
}
