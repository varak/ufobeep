package com.ufobeep

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class UFOBeepFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // Handle data payload for background notifications
        if (remoteMessage.data.isNotEmpty()) {
            val notificationType = remoteMessage.data["type"] ?: "general"
            val witnessCountStr = remoteMessage.data["witness_count"] ?: "1"
            val witnessCount = witnessCountStr.toIntOrNull() ?: 1

            // Log for debugging
            android.util.Log.d("FCM", "Background message received: type=$notificationType, witnesses=$witnessCount")

            when (notificationType) {
                "sighting_alert" -> handleSightingAlert(remoteMessage, witnessCount)
                "comment" -> handleCommentNotification(remoteMessage)
                else -> handleGeneralNotification(remoteMessage)
            }
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        android.util.Log.d("FCM", "New FCM token received: ${token.takeLast(6)}")
        // Token will be handled by Flutter DeviceRegistrationManager
    }

    private fun handleSightingAlert(message: RemoteMessage, witnessCount: Int) {
        val sightingId = message.data["sighting_id"] ?: return
        val distance = message.data["distance"]
        val locationName = message.data["location_name"] ?: "Unknown Location"

        // Format distance display
        val distanceText = distance?.toDoubleOrNull()?.let { dist ->
            if (dist < 1.0) " • ${(dist * 1000).toInt()}m away"
            else " • ${String.format("%.1f", dist)}km away"
        } ?: ""

        // Create urgency indicators
        val (urgencyIcon, witnessText) = when {
            witnessCount >= 10 -> "🚨" to "$witnessCount witnesses"
            witnessCount >= 3 -> "⚠️" to "$witnessCount witnesses"
            witnessCount > 1 -> "📢" to "$witnessCount witnesses"
            else -> "📢" to "New sighting"
        }

        val title = "$urgencyIcon UFO Sighting"
        val body = "$witnessText near $locationName$distanceText"

        showNotification(
            id = sightingId.hashCode(),
            title = title,
            body = body,
            channelId = "ufobeep_alerts",
            sightingId = sightingId,
            priority = if (witnessCount >= 10) NotificationCompat.PRIORITY_MAX else NotificationCompat.PRIORITY_HIGH
        )
    }

    private fun handleCommentNotification(message: RemoteMessage) {
        val sightingId = message.data["sighting_id"] ?: message.data["alert_id"] ?: return
        val title = message.notification?.title ?: "💬 New Comment"
        val body = message.notification?.body ?: "Someone commented on an alert"

        showNotification(
            id = sightingId.hashCode() + 1000, // Different ID from alert notifications
            title = title,
            body = body,
            channelId = "ufobeep_comments",
            sightingId = sightingId,
            priority = NotificationCompat.PRIORITY_HIGH
        )
    }

    private fun handleGeneralNotification(message: RemoteMessage) {
        val title = message.notification?.title ?: "UFOBeep"
        val body = message.notification?.body ?: "New notification"

        showNotification(
            id = System.currentTimeMillis().toInt(),
            title = title,
            body = body,
            channelId = "ufobeep_general",
            priority = NotificationCompat.PRIORITY_DEFAULT
        )
    }

    private fun showNotification(
        id: Int,
        title: String,
        body: String,
        channelId: String,
        sightingId: String? = null,
        priority: Int = NotificationCompat.PRIORITY_DEFAULT
    ) {
        ensureNotificationChannel(channelId)

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            sightingId?.let { putExtra("sighting_id", it) }
        }

        val pendingIntent = PendingIntent.getActivity(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setPriority(priority)
            .setAutoCancel(true)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(id, notification)
    }

    private fun ensureNotificationChannel(channelId: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (notificationManager.getNotificationChannel(channelId) != null) return

        val (name, description, importance, soundResId) = when (channelId) {
            "ufobeep_alerts" -> arrayOf(
                "UFOBeep Alerts",
                "Nearby sighting alerts with sound + vibration",
                NotificationManager.IMPORTANCE_HIGH,
                R.raw.ufobeep_chime
            )
            "ufobeep_comments" -> arrayOf(
                "Comment Notifications",
                "Notifications when someone comments on alerts you follow",
                NotificationManager.IMPORTANCE_DEFAULT,
                null
            )
            else -> arrayOf(
                "General Notifications",
                "General UFOBeep notifications",
                NotificationManager.IMPORTANCE_DEFAULT,
                null
            )
        }

        val channel = NotificationChannel(channelId, name as String, importance as Int).apply {
            this.description = description as String
            enableVibration(true)
            enableLights(true)
            setShowBadge(true)

            (soundResId as? Int)?.let { resId ->
                val soundUri = Uri.parse("android.resource://$packageName/$resId")
                val attrs = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
                setSound(soundUri, attrs)
            }
        }

        notificationManager.createNotificationChannel(channel)
    }
}