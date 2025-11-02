package com.panel.me

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    companion object {
        private const val TAG = "FCMService"
        private const val CHANNEL_ID = "admin_notifications"
    }
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "?? ===== NEW FCM TOKEN =====")
        Log.d(TAG, "?? Token: $token")
        
        // Save token locally
        saveTokenToPreferences(token)
        Log.d(TAG, "? Token saved to preferences")
    }
    
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        Log.d(TAG, "?? ===== MESSAGE RECEIVED =====")
        Log.d(TAG, "?? From: ${remoteMessage.from}")
        Log.d(TAG, "?? Message ID: ${remoteMessage.messageId}")
        Log.d(TAG, "?? Sent Time: ${remoteMessage.sentTime}")
        
        // Handle data payload
        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "?? Data payload: ${remoteMessage.data}")
            handleDataMessage(remoteMessage.data)
        } else {
            Log.d(TAG, "?? No data payload")
        }
        
        // Handle notification payload
        remoteMessage.notification?.let {
            Log.d(TAG, "?? Notification payload: ${it.title} - ${it.body}")
            showNotification(it.title ?: "New Notification", it.body ?: "", remoteMessage.data)
        } ?: run {
            Log.d(TAG, "?? No notification payload")
            // ??? notification ?????? ????? ??? data ????? ?????
            if (remoteMessage.data.isNotEmpty()) {
                Log.d(TAG, "?? Creating notification from data payload")
                showNotification(
                    remoteMessage.data["title"] ?: "New Notification",
                    remoteMessage.data["body"] ?: "You have a new notification",
                    remoteMessage.data
                )
            }
        }
        
        Log.d(TAG, "? Message processing complete")
    }
    
    private fun handleDataMessage(data: Map<String, String>) {
        val type = data["type"]
        
        when (type) {
            "device_registered" -> {
                val deviceId = data["device_id"] ?: ""
                val model = data["model"] ?: ""
                val appType = data["app_type"] ?: ""
                
                Log.d(TAG, "New device registered: $model ($appType)")
                
                showNotification(
                    "?? New Device Registered",
                    "$model ($appType)",
                    data
                )
            }
        }
    }
    
    private fun showNotification(title: String, body: String, data: Map<String, String>) {
        Log.d(TAG, "?? Showing notification: $title - $body")
        
        createNotificationChannel()
        
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            data.forEach { (key, value) ->
                putExtra(key, value)
            }
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this,
            System.currentTimeMillis().toInt(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setContentIntent(pendingIntent)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setVibrate(longArrayOf(0, 500, 500, 500))
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notificationId = System.currentTimeMillis().toInt()
        
        Log.d(TAG, "?? Notification ID: $notificationId")
        notificationManager.notify(notificationId, notificationBuilder.build())
        Log.d(TAG, "? Notification sent to system")
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Admin Notifications"
            val descriptionText = "Notifications for admin activities"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
            Log.d(TAG, "? Notification channel created/updated")
        }
    }
    
    private fun saveTokenToPreferences(token: String) {
        getSharedPreferences("FCM", Context.MODE_PRIVATE)
            .edit()
            .putString("token", token)
            .apply()
    }
}
