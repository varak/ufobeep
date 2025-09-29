//
//  UfobeepCameraCapsPlugin.swift
//  ufobeep_camera_caps
//
import Flutter
import UIKit
import AVFoundation

public class UfobeepCameraCapsPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ufobeep/caps", binaryMessenger: registrar.messenger())
    let instance = UfobeepCameraCapsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCaps":
      result(getCaps())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getCaps() -> [String: Any] {
    var minX: CGFloat = 1.0
    var maxX: CGFloat = 8.0
    var anchors: [Double] = [1.0]

    if let back = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
      if #available(iOS 17.0, *) {
        maxX = back.maxAvailableVideoZoomFactor
      } else {
        maxX = back.activeFormat.videoMaxZoomFactor
      }
      var acc: [Double] = []
      if #available(iOS 13.0, *) {
        if AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) != nil {
          acc.append(0.5)
        }
        if AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) != nil {
          acc.append(2.0)
          acc.append(3.0)
        }
      }
      acc.append(1.0)
      acc = acc.filter { $0 <= Double(maxX) }
      if !acc.isEmpty { anchors = Array(Set(acc)).sorted() }
      if maxX < minX { maxX = minX }
    }

    return ["minX": Double(minX), "maxX": Double(maxX), "anchorsX": anchors]
  }
}
