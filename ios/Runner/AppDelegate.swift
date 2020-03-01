import UIKit
import Flutter
import AVFoundation


@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    
    override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        GeneratedPluginRegistrant.register(with: self)
    
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
    
    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //set audio session to be on background always
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

let kOverlayStyleUpdateNotificationName = "io.flutter.plugin.platform.SystemChromeOverlayNotificationName"
let kOverlayStyleUpdateNotificationKey = "io.flutter.plugin.platform.SystemChromeOverlayNotificationKey"

extension FlutterViewController {
    private struct StatusBarStyleHolder {
        static var style: UIStatusBarStyle = .default
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appStatusBar(notification:)),
            name: NSNotification.Name(kOverlayStyleUpdateNotificationName),
            object: nil
        )
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusBarStyleHolder.style
    }
    
    @objc private func appStatusBar(notification: NSNotification) {
        guard
            let info = notification.userInfo as? Dictionary<String, Any>,
            let statusBarStyleKey = info[kOverlayStyleUpdateNotificationKey] as? Int
        else {
            return
        }
        
        if #available(iOS 13.0, *) {
            StatusBarStyleHolder.style = statusBarStyleKey == 0 ? .darkContent : .lightContent
        } else {
            StatusBarStyleHolder.style = statusBarStyleKey == 0 ? .default : .lightContent
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
}

