import Flutter
import UIKit
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var clickSoundID: SystemSoundID = 0
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
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
}
