//
//  TransactionInfoWebViewController.swift
//  DiveLane
//
//  Created by Francesco on 13/10/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import WebKit

class TransactionInfoWebController: UIViewController {
    static let nibName = "TransactionInfoWebController"

    enum Constants {
        static let baseUrl = "https://etherscan.io/tx/"
    }

    // MARK: @IBOutlet
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!

    var transactionHash: String = ""
    var lastOffsetY = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction Info"
        setupCloseButton()
        trackPageLoadingProgress()
        loadRequest(for: transactionHash)
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: "web_close"), for: .normal)
        closeButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        closeButton.tintColor = .black
        closeButton.sizeToFit()

        let barButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = barButtonItem
    }

    private func loadRequest(for hash: String) {
        let urlString = Constants.baseUrl + hash
        guard let url = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
    }

    var observer: NSKeyValueObservation?
    private func trackPageLoadingProgress() {
        observer = webView.observe(\.estimatedProgress, options: .new) { (_, change) in
            print(change.newValue ?? "nil")
            self.progressView.progress = Float(self.webView.estimatedProgress)
        }
    }

    @IBAction private func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}

extension TransactionInfoWebController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }
}

extension TransactionInfoWebController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

        let hide = scrollView.contentOffset.y > self.lastOffsetY
        navigationController?.setNavigationBarHidden(hide, animated: true)
    }
}
