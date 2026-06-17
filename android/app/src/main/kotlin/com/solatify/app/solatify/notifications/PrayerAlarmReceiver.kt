package com.solatify.app.solatify.notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.solatify.app.solatify.R

class PrayerAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != PrayerAlarmScheduler.ACTION_PRAYER_ALARM) return

        ensureNotificationChannel(context)

        val id = intent.getIntExtra(PrayerAlarmScheduler.EXTRA_ID, 0)
        val title = intent.getStringExtra(PrayerAlarmScheduler.EXTRA_TITLE) ?: "Waktu Salat"
        val body = intent.getStringExtra(PrayerAlarmScheduler.EXTRA_BODY) ?: "Telah masuk waktu salat."
        val prayerKey = intent.getStringExtra(PrayerAlarmScheduler.EXTRA_PRAYER_KEY) ?: "prayer"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "POST_NOTIFICATIONS denied; cannot show prayer notification id=$id")
            return
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setSound(adhanSoundUri(context))
            .setVibrate(longArrayOf(0, 700, 300, 700))
            .setOnlyAlertOnce(false)
            .addExtras(android.os.Bundle().apply { putString("prayerKey", prayerKey) })
            .build()

        NotificationManagerCompat.from(context).notify(id, notification)
        PrayerAlarmScheduler(context).cancel(id)
        Log.d(TAG, "Displayed prayer notification id=$id prayer=$prayerKey")
    }

    companion object {
        private const val TAG = "PrayerAlarmReceiver"
    }
}

const val CHANNEL_ID = "prayer_times_adhan_channel_v7"

fun ensureNotificationChannel(context: Context) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

    val channel = NotificationChannel(
        CHANNEL_ID,
        "Prayer Times Adhan",
        NotificationManager.IMPORTANCE_HIGH,
    ).apply {
        description = "Adhan notifications for prayer times"
        enableVibration(true)
        setSound(
            adhanSoundUri(context),
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build(),
        )
    }

    val manager = context.getSystemService(NotificationManager::class.java)
    manager.createNotificationChannel(channel)
}

fun adhanSoundUri(context: Context): Uri {
    return Uri.parse("android.resource://${context.packageName}/raw/adhan")
}
