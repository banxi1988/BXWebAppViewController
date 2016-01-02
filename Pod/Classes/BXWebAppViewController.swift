
import ReachabilitySwift

public let BXWebAppViewControllerShouldReloadNotification = "BXWebAppViewControllerShouldReloadNotification"

public func createWebAppViewController(URL:NSURL) -> BXWebAppViewController{
  let vc  =  BXWKWebViewViewController()
  vc.webURL = URL
  return vc
}

public func createWebAppViewController(HTMLString:String,baseURL:NSURL?=nil) -> BXWebAppViewController{
  let vc  =  BXWKWebViewViewController()
  vc.webHTMLString = HTMLString
  vc.baseURL = baseURL
  return vc
}

public class BXWebAppViewController:UIViewController{
  // MARK: View Create
  // common view
  public lazy var progressView:UIProgressView = {
    let progressView = UIProgressView(progressViewStyle: .Default)
    progressView.progress = 0.0
    progressView.progressTintColor = self.view.tintColor
    return progressView
  }()
  public lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    indicator.color = self.view.tintColor
    return indicator
    
  }()
  
  public lazy var errorTipView:BXNetworkErrorTipView = {
     return  BXNetworkErrorTipView()
  }()
 
  public var webURL:NSURL?
  public var webHTMLString:String?
  public var baseURL:NSURL?
  
  // MARK: WebApp Interface flag
  var shouldReload  = false //
  var clear_stack = false //
  var isWebAppStackRoot = false
  var isTabRoot = false
  lazy var httpReachablility = try? Reachability.reachabilityForInternetConnection()
  
  
  override public func loadView() {
    super.loadView()
    self.view.backgroundColor = UIColor.whiteColor()
    view.addSubview(progressView)
    view.addSubview(activityIndicator)
    installConstraints()
  }
  
  func installConstraints(){
    for childView in [progressView,activityIndicator]{
      childView.translatesAutoresizingMaskIntoConstraints = false
    }
    pinTopLayoutGuide(progressView)
    progressView.pinHorizontal(0)
    activityIndicator.pinCenter()
  }
  
  func installWebView(webview:UIView){
    if view.subviews.contains(webview){
      return
    }
    view.addSubview(webview)
    view.sendSubviewToBack(webview)
    webview.translatesAutoresizingMaskIntoConstraints = false
    pinTopLayoutGuide(webview)
    pinBottomLayoutGuide(webview)
    webview.pinHorizontal(0)
  }
  
  func closeSelf(){
    let poped = navigationController?.popViewControllerAnimated(true)
    if poped == nil{
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
 
  deinit{
      NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    automaticallyAdjustsScrollViewInsets = false
    NSNotificationCenter.defaultCenter().addObserverForName(BXWebAppViewControllerShouldReloadNotification, object: nil, queue: nil) { (notif) -> Void in
      self.reload()
    }
    if let URL = webURL{
      loadURL(URL)
    }else if let html = webHTMLString{
      loadHTMLString(html,baseURL: baseURL)
    }
  }
  
  // MARK: WebApp Bridge Method
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if shouldReload{
      reload()
    }
    
  }
  
  public func loadURL(URL:NSURL){
    webURL = URL
    loadRequest(NSMutableURLRequest(URL: URL))
  }
  
  public func reload(){
    errorTipView.removeFromSuperview()
  }
  
  // MARK  Abstract method
  public func loadRequest(req:NSMutableURLRequest){
    fatalError("NotImplemented")
  }
  
  public func loadHTMLString(html:String,baseURL:NSURL?=nil){
    fatalError("NotImplemented")
  }
  
  public func evaluateJavaScript(js:String){
    fatalError("NotImplemented")
  }
  
  // MARK Helpe Method
  func showErrorView(){
    let errorView = errorTipView
    errorView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(errorView)
    errorView.pinEdge(UIEdgeInsetsZero)
    errorView.actionButton.addTarget(self, action: "reload", forControlEvents: .TouchUpInside)
  }
  
}