package com.ufobeep.camera_caps

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs

class UfobeepCameraCapsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var appContext: Context

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "ufobeep/caps")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getCaps" -> result.success(getCaps())
      else -> result.notImplemented()
    }
  }

  private fun getCaps(): Map<String, Any> {
    val cm = appContext.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    var maxZoom = 8.0f
    val minZoom = 1.0f
    val anchors = linkedSetOf<Double>()

    try {
      for (id in cm.cameraIdList) {
        val ch = cm.getCameraCharacteristics(id)
        val facing = ch.get(CameraCharacteristics.LENS_FACING)
        if (facing == CameraCharacteristics.LENS_FACING_BACK) {
          ch.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM)?.let { maxZoom = it }

          val focals = ch.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)
          if (focals != null && focals.isNotEmpty()) {
            val sorted = focals.sorted()
            val base = sorted[sorted.size / 2] // heuristic 1× baseline
            val candidates = listOf(0.5, 0.6, 0.7, 1.0, 2.0, 3.0, 5.0, 10.0)
            for (f in sorted) {
              val ratio = (f / base).toDouble()
              var best = candidates.first()
              var bestDist = Double.MAX_VALUE
              for (c in candidates) {
                val d = abs(c - ratio)
                if (d < bestDist) { best = c; bestDist = d }
              }
              if (bestDist <= 0.22) anchors.add(best)
            }
          }
          break
        }
      }
    } catch (e: Exception) {
      // keep defaults
    }

    if (anchors.isEmpty()) anchors.add(1.0)
    val ax = anchors.filter { it <= maxZoom.toDouble() }.sorted()
    return mapOf("minX" to minZoom.toDouble(), "maxX" to maxZoom.toDouble(), "anchorsX" to ax)
  }
}
