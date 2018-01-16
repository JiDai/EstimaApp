//
//  ViewController.swift
//  MeilleursAgentsIOS
//
//  Created by Jordi Dosne on 06/01/2018.
//  Copyright © 2018 MeilleursAgents. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet var webView: UIWebView!
    var progressView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseUrl = Bundle.main.infoDictionary?["WWW_BASE_URL"] as! String
        let cookieDomain = Bundle.main.infoDictionary?["COOKIE_DOMAIN"] as! String
        
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.webView.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height - 20)
        
        // add progress indicator
        progressView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        progressView.frame = CGRect(origin: CGPoint(x: self.view.frame.size.width/2 - progressView.frame.size.width/2, y: self.view.frame.size.height/2 - progressView.frame.size.height/2), size: self.view.frame.size)
        progressView.sizeToFit()
        progressView.startAnimating()
        self.view.addSubview(progressView)
        
        // Set cookie to identify Webview users
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        setCookie(key: "estimaWebView", value: "1", domain: cookieDomain)
        setCookie(key: "ab_dispatcher", value: "99", domain: cookieDomain)
        setCookie(key: "deploy_dispatcher", value: "99", domain: cookieDomain)
        
        // Load webview
        let url = URL(string: baseUrl + "estimation-immobiliere/form?utm_source=app_ios&utm_medium=app_mobile&utm_campaign=application_estima_201802")
        let req = URLRequest(url: url!)
        self.webView.loadRequest(req)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        progressView.removeFromSuperview()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let pathsAuthorizedInWebview = [
            "/estimation-immobiliere/form",
            "/estimation-immobiliere/result",
            "/estimation-immobiliere/terms",
            ]
        if navigationType == UIWebViewNavigationType.linkClicked {
            if pathsAuthorizedInWebview.contains((request.url?.relativePath)!) {
                return true
            }
            else {
                UIApplication.shared.open(request.url!)
                return false
            }

        }
        return true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

