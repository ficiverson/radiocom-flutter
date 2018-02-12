import UIKit
import Flutter


@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    
    override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        GeneratedPluginRegistrant.register(with: self)
    
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
    
    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            UIView.animate(withDuration: 1.0, animations: {
                webView.alpha = 0
            }, completion: { _ in
                webView.removeFromSuperview()
            })
        }
    }
}
