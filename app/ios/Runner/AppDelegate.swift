import UIKit
import AudioToolbox
import UserNotifications
@_exported import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var clickSoundID: SystemSoundID = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Request notification permissions and register for remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if granted {
            DispatchQueue.main.async {
              application.registerForRemoteNotifications()
            }
          }
        }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
      application.registerForRemoteNotifications()
    }

    // Setup UI SFX channel for native sound feedback
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "ui_sfx", binaryMessenger: controller.binaryMessenger)
    
    // Load ui_click sound from resources
    if let soundURL = Bundle.main.url(forResource: "ui_click", withExtension: "wav") {
      AudioServicesCreateSystemSoundID(soundURL as CFURL, &clickSoundID)
    }
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "warm":
        // iOS doesn't need warm-up like Android/Moto devices
        result(true)
      case "click":
        if let soundID = self?.clickSoundID, soundID != 0 {
          // Play system sound with lowest latency
          AudioServicesPlaySystemSound(soundID)
        }
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle successful registration for remote notifications
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ APNS device token received")
    // Pass the token to Flutter/Firebase
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Handle failure to register for remote notifications
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error)")
  }
}
