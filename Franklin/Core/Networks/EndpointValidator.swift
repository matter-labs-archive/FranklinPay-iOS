//
//  EndpointValidator.swift
//  Franklin
//
//  Created by Anton on 14/03/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public enum EndpointError: Error {
    case wrongChar(_ char: String)
    case wrongPrefix(_ char: String)
    case wrongSuffix(_ char: String)
}

extension EndpointError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .wrongChar(let char):
            return NSLocalizedString("Endpoint can't contain '\(char)'", comment: "Wrong char error")
        case .wrongPrefix(let prefix):
            return NSLocalizedString("Endpoint can't start with '\(prefix)'", comment: "Wrong prefix error")
        case .wrongSuffix(let suffix):
            return NSLocalizedString("Endpoint can't end with '\(suffix)'", comment: "Wrong suffix error")
        }
    }
}

public class EndpointValidator {
    
    func checkEnpointAndReturnError(endpoint: String) -> EndpointError? {
        if endpoint.hasPrefix("/") {
            return EndpointError.wrongPrefix("/")
        }
        if endpoint.hasSuffix("//") {
            return EndpointError.wrongSuffix("//")
        }
        if !(endpoint.hasSuffix("https://") || endpoint.hasSuffix("http://")) && endpoint.contains(":") {
            return EndpointError.wrongChar(":")
        }
        if endpoint.contains(",") {
            return EndpointError.wrongChar(",")
        }
        if endpoint.contains("@") {
            return EndpointError.wrongChar("@")
        }
        if endpoint.contains("#") {
            return EndpointError.wrongChar("#")
        }
        if endpoint.contains("%") {
            return EndpointError.wrongChar("%")
        }
        if endpoint.contains("^") {
            return EndpointError.wrongChar("^")
        }
        if endpoint.contains("&") {
            return EndpointError.wrongChar("&")
        }
        if endpoint.contains("*") {
            return EndpointError.wrongChar("*")
        }
        if endpoint.contains("(") {
            return EndpointError.wrongChar("(")
        }
        if endpoint.contains(")") {
            return EndpointError.wrongChar(")")
        }
        if endpoint.contains("~") {
            return EndpointError.wrongChar("~")
        }
        if endpoint.contains("]") {
            return EndpointError.wrongChar("]")
        }
        if endpoint.contains("[") {
            return EndpointError.wrongChar("[")
        }
        if endpoint.contains(";") {
            return EndpointError.wrongChar(";")
        }
        if endpoint.contains("'") {
            return EndpointError.wrongChar("'")
        }
        if endpoint.contains("\"") {
            return EndpointError.wrongChar("\"")
        }
        if endpoint.contains("\\") {
            return EndpointError.wrongChar("\\")
        }
        if endpoint.contains(">") {
            return EndpointError.wrongChar(">")
        }
        if endpoint.contains("<") {
            return EndpointError.wrongChar("<")
        }
        return nil
    }
}
