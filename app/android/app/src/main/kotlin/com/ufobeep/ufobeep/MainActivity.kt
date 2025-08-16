package com.ufobeep.ufobeep

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
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
    }
}
