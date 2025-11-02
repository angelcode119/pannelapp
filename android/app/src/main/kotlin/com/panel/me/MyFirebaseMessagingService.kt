package com.panel.me

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    companion object {
        private const val CHANNEL_ID = "admin_notifications"
    }
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        saveTokenToPreferences(token)
    }
    
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        // Handle notification payload
        remoteMessage.notification?.let {
            showNotification(it.title ?: "New Notification", it.body ?: "", remoteMessage.data)
        } ?: run {
            // ??? notification ?????? ????? ??? data ????? ?????
            if (remoteMessage.data.isNotEmpty()) {
                showNotification(
                    remoteMessage.data["title"] ?: "New Notification",
                    remoteMessage.data["body"] ?: "You have a new notification",
                    remoteMessage.data
                )
            }
        }
    }
    
    private fun showNotification(title: String, body: String, data: Map<String, String>) {
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
        
        notificationManager.notify(notificationId, notificationBuilder.build())
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
        }
    }
    
    private fun saveTokenToPreferences(token: String) {
        getSharedPreferences("FCM", Context.MODE_PRIVATE)
            .edit()
            .putString("token", token)
            .apply()
    }
}
