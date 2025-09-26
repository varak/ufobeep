package com.ufobeep

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.SoundPool
import android.net.Uri
import android.os.Bundle
import java.io.File
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ufobeep/share_intent"
    private val UI_SFX_CHANNEL = "ui_sfx"
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
        
        // Share intent channel
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
        
        // UI SFX channel for native soundpool
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UI_SFX_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "warm" -> {
                    UiSfx.ensureInitialized(this)
                    UiSfx.warm()
                    result.success(true)
                }
                "click" -> {
                    UiSfx.ensureInitialized(this)
                    UiSfx.click()
                    result.success(true)
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

object UiSfx {
    private var pool: SoundPool? = null
    private var soundId: Int = 0
    @Volatile private var loaded = false
    @Volatile private var warmed = false

    fun ensureInitialized(ctx: Context) {
        if (pool != null) return
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        pool = SoundPool.Builder()
            .setMaxStreams(2)
            .setAudioAttributes(attrs)
            .build()
        soundId = pool!!.load(ctx, R.raw.normal_beep, 1)
        pool!!.setOnLoadCompleteListener { _, sampleId, status ->
            loaded = (status == 0 && sampleId == soundId)
        }
    }

    fun warm() {
        if (!loaded || warmed) return
        val id = pool!!.play(soundId, 0f, 0f, 1, 0, 1f) // silent prime
        Thread {
            try { Thread.sleep(120) } catch (_: InterruptedException) {}
            try { pool?.stop(id) } catch (_: Exception) {}
            warmed = true
        }.start()
    }

    fun click() {
        if (!loaded) return
        pool!!.play(soundId, 1f, 1f, 1, 0, 1f)
    }
}
