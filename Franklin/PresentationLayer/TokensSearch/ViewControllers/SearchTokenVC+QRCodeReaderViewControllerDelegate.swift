//
//  SearchTokenVC+QR.swift
//  Franklin
//
//  Created by Anton on 22/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader

extension SearchTokenViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let searchText = result.value.lowercased()
        self.searchTextField.text = searchText
        reader.dismiss(animated: true)
        //        DispatchQueue.main.async { [weak self] in
        //
        //            self?.searchBar(searchBar, textDidChange: searchText)
        //        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true)
    }
}
