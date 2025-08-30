package com.ufobeep

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
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
        
        // Fix notification channel with proper sound + vibration
        ensureBeepChannelFixed()
        
        // Handle share intent
        handleShareIntent(intent)
    }
    
    private fun ensureBeepChannelFixed() {
        val channelId = "ufobeep_alerts"
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = nm.getNotificationChannel(channelId)
        
        val desiredSound = Uri.parse("android.resource://$packageName/${R.raw.ufobeep_chime}")
        val desiredImportance = NotificationManager.IMPORTANCE_HIGH
        val desiredVibration = longArrayOf(0, 300, 120, 300)
        
        var needsFix = false
        if (existing == null) {
            needsFix = true
        } else {
            // Check if channel needs fixing
            if (existing.importance < desiredImportance) needsFix = true
            if (!existing.shouldVibrate()) needsFix = true
            if (existing.sound == null) needsFix = true
        }
        
        if (needsFix) {
            // Delete and recreate channel with correct settings
            try { 
                nm.deleteNotificationChannel(channelId) 
            } catch (_: Exception) {}
            
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION_EVENT)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
                
            val ch = NotificationChannel(channelId, "UFOBeep Alerts", desiredImportance).apply {
                description = "Nearby sighting alerts with sound + vibration"
                setSound(desiredSound, attrs)
                enableVibration(true)
                vibrationPattern = desiredVibration
                enableLights(true)
                setShowBadge(true)
            }
            nm.createNotificationChannel(ch)
        }
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
