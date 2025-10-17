import UIKit
import AudioToolbox
import UserNotifications
import AVFoundation
import CoreLocation
import Photos
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
    let sfxChannel = FlutterMethodChannel(name: "ui_sfx", binaryMessenger: controller.binaryMessenger)

    // Load ui_click sound from resources
    if let soundURL = Bundle.main.url(forResource: "ui_click", withExtension: "wav") {
      AudioServicesCreateSystemSoundID(soundURL as CFURL, &clickSoundID)
    }

    sfxChannel.setMethodCallHandler { [weak self] (call, result) in
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

    // Setup permissions channel for accurate iOS permission checking
    let permissionsChannel = FlutterMethodChannel(name: "ios_permissions", binaryMessenger: controller.binaryMessenger)
    permissionsChannel.setMethodCallHandler { (call, result) in
      if call.method == "checkPermission" {
        guard let args = call.arguments as? [String: Any],
              let type = args["type"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing permission type", details: nil))
          return
        }

        switch type {
        case "location":
          let status = CLLocationManager.authorizationStatus()
          result(status == .authorizedAlways || status == .authorizedWhenInUse)

        case "camera":
          let status = AVCaptureDevice.authorizationStatus(for: .video)
          result(status == .authorized)

        case "photos":
          let status = PHPhotoLibrary.authorizationStatus()
          if #available(iOS 14, *) {
            result(status == .authorized || status == .limited)
          } else {
            result(status == .authorized)
          }

        case "notification":
          if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
              result(settings.authorizationStatus == .authorized)
            }
          } else {
            result(UIApplication.shared.isRegisteredForRemoteNotifications)
          }

        default:
          result(FlutterError(code: "UNKNOWN_TYPE", message: "Unknown permission type: \(type)", details: nil))
        }
      } else {
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
