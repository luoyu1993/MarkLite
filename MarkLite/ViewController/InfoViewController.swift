//
//  InfoViewController.swift
//  MarkLite
//
//  Created by 朱炳程 on 2018/10/10.
//  Copyright © 2018 zhubch. All rights reserved.
//

import UIKit
import WebKit

class InfoViewController: UIViewController, WKNavigationDelegate {
    
    let webView = WKWebView(frame: CGRect())
    var url = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
        webView.frame = self.view.bounds
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.stopLoadingAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = self.view.bounds
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.stopLoadingAnimation()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.stopLoadingAnimation()
    }
}
