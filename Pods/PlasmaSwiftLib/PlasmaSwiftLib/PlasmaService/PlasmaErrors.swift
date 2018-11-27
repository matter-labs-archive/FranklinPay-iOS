//
//  Errors.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation

enum NetErrors: Error {
    case cantCreateRequest
    case cantConvertTxData
    case noData
    case errorInListUTXOs
    case errorInUTXOs
    case noAcceptedInfo
    case badResponse
}

enum StructureErrors: Error {
    case cantDecodeData
    case cantEncodeData
    case dataIsNotArray
    case isNotList
    case wrongDataCount
    case isNotData
    case wrongBitWidth
    case wrongData
    case wrongKey
    case wrongAddress
}
