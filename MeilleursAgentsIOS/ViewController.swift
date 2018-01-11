//
//  ViewController.swift
//  MeilleursAgentsIOS
//
//  Created by Jordi Dosne on 06/01/2018.
//  Copyright © 2018 MeilleursAgents. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController , WKNavigationDelegate {
    @IBOutlet var webView: WKWebView!
    var progressView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseUrl = Bundle.main.infoDictionary?["WWW_BASE_URL"] as! String
        let cookieDomain = Bundle.main.infoDictionary?["COOKIE_DOMAIN"] as! String
        
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.webView.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height - 20)
        self.webView.navigationDelegate = self
        
        // add observer for key path
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        // add progresbar to navigation bar
        progressView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        progressView.frame = CGRect(origin: CGPoint(x: self.view.frame.size.width/2 - progressView.frame.size.width/2, y: self.view.frame.size.height/2 - progressView.frame.size.height/2), size: self.view.frame.size)
        progressView.sizeToFit()
        self.view.addSubview(progressView)
        
        
        // Set cookie to identify Webviw users
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        setCookie(key: "estimaWebWiew", value: "1", domain: cookieDomain)
        setCookie(key: "ab_dispatcher", value: "99", domain: cookieDomain)
        setCookie(key: "deploy_dispatcher", value: "99", domain: cookieDomain)
        
        // Load webview
        let url = URL(string: baseUrl)
        let req = URLRequest(url: (url?.appendingPathComponent("estimation-immobiliere/result?estima_id=9503565", isDirectory: false))!)
        self.webView.load(req)
    }
    
    deinit {
        //remove all observers
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        //remove progress bar from navigation bar
        progressView.removeFromSuperview()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            debugPrint("progress", webView.estimatedProgress)
            if(webView.estimatedProgress < 1) {
                progressView.startAnimating()
            }
            else {
                progressView.stopAnimating()
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        let pathsAuthorizedInWebview = [
            "/estimation-immobiliere/form",
            "/estimation-immobiliere/result",
            ]
        debugPrint(navigationAction.request.url!)
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil {
                self.webView?.load(navigationAction.request)
            }
            if pathsAuthorizedInWebview.contains((navigationAction.request.url?.relativePath)!) {
                decisionHandler(.allow)
            }
            else {
                UIApplication.shared.open(navigationAction.request.url!)
                decisionHandler(.cancel)
            }
            
        default:
            break
        }
        
        decisionHandler(.allow)
    }
    
    
    func setCookie(key: String, value: String, domain: String) {
        let cookieProps: [HTTPCookiePropertyKey : Any] = [
            HTTPCookiePropertyKey.domain: domain,
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: key,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.secure: "TRUE",
            HTTPCookiePropertyKey.expires: NSDate(timeIntervalSinceNow:TimeInterval(60 * 60 * 24 * 365))
        ]
        
        if let cookie = HTTPCookie(properties: cookieProps) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }
    
}

