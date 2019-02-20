//
//  Method.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public enum Method: String {
    case post = "POST"
    case get = "GET"
}

public enum ContentType: String {
    case json = "application/json"
    case octet = "application/octet-stream"
}
