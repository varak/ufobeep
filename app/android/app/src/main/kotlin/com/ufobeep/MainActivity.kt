package com.ufobeep

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import java.io.File
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ufobeep/share_intent"
    private var sharedFileUri: Uri? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create high-priority notification channel for UFO alerts
        val channel = NotificationChannel(
            "ufobeep_alerts",
            "UFOBeep Alerts",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Urgent UFO sighting alerts from nearby witnesses"
            enableVibration(true)
            setShowBadge(true)
        }
        
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(channel)
        
        // Handle share intent
        handleShareIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedFile" -> {
                    val fileUri = sharedFileUri?.toString()
                    sharedFileUri = null // Clear after reading
                    result.success(fileUri)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent?) {
        when {
            intent?.action == Intent.ACTION_SEND && intent.type?.startsWith("image/") == true -> {
                processSharedMedia(intent.getParcelableExtra(Intent.EXTRA_STREAM), "shared_image")
            }
            intent?.action == Intent.ACTION_SEND && intent.type?.startsWith("video/") == true -> {
                processSharedMedia(intent.getParcelableExtra(Intent.EXTRA_STREAM), "shared_video")
            }
        }
    }

    private fun processSharedMedia(uri: Uri?, prefix: String) {
        uri?.let { sourceUri ->
            contentResolver.openInputStream(sourceUri)?.use { input ->
                File.createTempFile(prefix, null, cacheDir).apply {
                    outputStream().use(input::copyTo)
                    sharedFileUri = Uri.fromFile(this)
                }
            }
        }
    }
}
