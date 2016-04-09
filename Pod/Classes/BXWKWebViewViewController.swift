//
//  BXWKWebViewViewController.swift
//  Pods
//
//  Created by Haizhen Lee on 15/12/8.
//
//

import UIKit
import WebKit

public class BXWKWebViewViewController: BXWebAppViewController,WKScriptMessageHandler,WKNavigationDelegate{
 
  public var defaultMessageHandlerName = "BX"
  
// Build for target const
// -KVOKeyPaths
// estimatedProgress;title;loading;canGoBack
struct KVOKeyPaths  {
    static let estimatedProgress =  "estimatedProgress"
    static let title =  "title"
    static let loading =  "loading"
    static let canGoBack =  "canGoBack"
    static let allConsts:[String] = [estimatedProgress,title,loading,canGoBack]
    private static var kvoContext = "kvo"
}
  
  public lazy var webView:WKWebView = {
   let ucc = WKUserContentController()
    ucc.addScriptMessageHandler(self, name: self.defaultMessageHandlerName)
    let config = WKWebViewConfiguration()
    config.userContentController = ucc
    let webview = WKWebView(frame: CGRectZero, configuration: config)
    webview.navigationDelegate = self
    webview.allowsBackForwardNavigationGestures = true
    for keyPath in KVOKeyPaths.allConsts{
      webview.addObserver(self, forKeyPath: keyPath, options: .New, context: &KVOKeyPaths.kvoContext)
    }
    return webview
  }()
  
  public var userContentController:WKUserContentController{
    return webView.configuration.userContentController
  }

  lazy var backButtonItem : UIBarButtonItem = {
    return UIBarButtonItem(title:"返回",style:.Plain, target: self, action: #selector(back(_:)))
  }()
  
  lazy var closeButtonItem : UIBarButtonItem = {
    return UIBarButtonItem(title:"关闭",style:.Plain, target: self, action: #selector(close(_:)))
  }()
  
  public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
  }
  
  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if context != &KVOKeyPaths.kvoContext || keyPath == nil{
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
      return
    }
    
    switch keyPath!{
    case KVOKeyPaths.estimatedProgress:
      let shouldHidden = webView.estimatedProgress == 1.0
      progressView.hidden = shouldHidden
      activityIndicator.hidden = shouldHidden
      if shouldHidden{
        activityIndicator.stopAnimating()
      }else{
        activityIndicator.startAnimating()
      }
      progressView.progress = Float(webView.estimatedProgress)
    case KVOKeyPaths.title:
//      title = webView.title
      navigationItem.title = webView.title
    case KVOKeyPaths.loading:
      break // estimatedProgress already do the work
    case KVOKeyPaths.canGoBack:
      closeButtonItem.enabled = webView.canGoBack
      if webView.canGoBack{
        navigationItem.leftBarButtonItems = [backButtonItem,closeButtonItem]
      }else{
        navigationItem.leftBarButtonItems = [backButtonItem]
      }
    default:break
    }
  }
  
  deinit{
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  public override func loadView() {
    super.loadView()
    installWebView(webView)
  }
  
    override public func viewDidLoad() {
        super.viewDidLoad()

    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func back(sender:AnyObject){
    if webView.canGoBack{
      webView.goBack()
    }else{
      closeSelf()
    }
  }
  
  @IBAction func close(sender:AnyObject){
    closeSelf()
  }
  
  
  // MARK: Implement Base Method
  override public func loadRequest(req: NSMutableURLRequest) {
    webView.loadRequest(req)
  }
  
  override public func evaluateJavaScript(js: String) {
    webView.evaluateJavaScript(js){
      (obj,error) -> Void in
      NSLog("evaluateJavaScript Result obj=\(obj), error=\(error)")
    }
  }
  
  override public func loadHTMLString(html:String,baseURL:NSURL?=nil){
    webView.loadHTMLString(html, baseURL: baseURL)
  }
  
  override public func reload() {
    super.reload()
    webView.reload()
  }
  
  // MARK: WKNavigationDelegate
  public func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
  }
  
  public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
  
  public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    if error.code == NSURLErrorCancelled{
      NSLog("didFailNavigation errorcancelled")
      return
    }
    
    if let failingUrl = error.userInfo[NSURLErrorFailingURLStringErrorKey] as? String {
      if failingUrl == webURL?.absoluteString{
        showErrorView()
      }
    }
    
  }

}

