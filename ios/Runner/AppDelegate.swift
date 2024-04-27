import UIKit
import Flutter
import flutter_background_service_ios

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  if #available(iOS 10.0, *){
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
  }

    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.minseok.helmy"

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
