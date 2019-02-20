//
//  ContactEquatable.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

extension Contact: Equatable {
    public static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.address == rhs.address
    }
}
