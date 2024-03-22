import UIKit
import Flutter
import GoogleSignIn 
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     GIDSignIn.sharedInstance().clientID = "http://925451517026-ehn5lnum0u5j5llt469gp71rn9rbh3he.apps.googleusercontent.com"
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyAJaYpwa5z9P61L9h0_JR-d3yoqMfDNhHY")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
   override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if GIDSignIn.sharedInstance().handle(url) {
            return true
        }
        return super.application(app, open: url, options: options)
    }

}
