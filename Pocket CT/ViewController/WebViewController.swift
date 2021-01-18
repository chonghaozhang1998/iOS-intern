//
//  WebViewController.swift
//  webViewDemo
//
//  Created by llj on 2020/10/28.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView!
    var progressView: UIProgressView!
    var urlString: String?
    var titleString: String?
    var progressObservation: NSKeyValueObservation?
    
    init(){
        super.init(nibName:nil, bundle:nil)
    }
    
    convenience init(urlString url:String, title: String?){
        self.init()
        print(url)
        self.urlString = url
        self.titleString = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        progressObservation = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let navHeight = navigationController?.navigationBar.frame.height ?? 0 // 44
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0 // 48
        let topPadding = navHeight + statusBarHeight
        
        print(navHeight)
        print(statusBarHeight)
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .init(x: 0, y: topPadding, width: view.bounds.width, height: view.bounds.height - topPadding), configuration: webConfiguration)
        view.addSubview(webView)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        let url = URL(string: urlString!)
        let request = URLRequest(url: url!)
        webView.load(request)
        
        setupProgressView(top: topPadding)
    }
    
    func setupProgressView(top: CGFloat) {
        progressView = UIProgressView(frame: CGRect(x: 0, y: top, width: view.bounds.width, height: 10))
        view.addSubview(progressView)
        progressView.progress = 0.0
        progressView.tintColor = .systemBlue
        
        progressObservation = webView.observe(\.estimatedProgress, options: .new, changeHandler: { (webView, change) in
            let newVlaue = change.newValue ?? 0
            print("new value: \(newVlaue)")
            
            self.progressView.alpha = 1.0
            self.progressView.setProgress(Float(newVlaue), animated: true)
            if newVlaue >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut) {
                    self.progressView.alpha = 0.0
                } completion: { (_) in
                    self.progressView.progress = 0
                }

            }
        })
        

    }

}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = webView.title!.isEmpty ? titleString : webView.title
    }
}
