//
//  SendMoneyVC+QR.swift
//  Franklin
//
//  Created by Anton on 21/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader

extension SendMoneyController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        topTextField.text = result.value
        reader.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
}
