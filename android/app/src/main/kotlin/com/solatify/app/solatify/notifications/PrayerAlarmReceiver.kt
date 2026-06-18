package com.solatify.app.solatify.notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
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
import com.solatify.app.solatify.service.AdhanPlaybackService

class PrayerAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != PrayerAlarmScheduler.ACTION_PRAYER_ALARM) return

        ensureNotificationChannels(context)

        val id = intent.getIntExtra(PrayerAlarmScheduler.EXTRA_ID, 0)
        val baseTitle = intent.getStringExtra(PrayerAlarmScheduler.EXTRA_TITLE) ?: "Waktu Salat"
        val baseBody = intent.getStringExtra(PrayerAlarmScheduler.EXTRA_BODY) ?: "Telah masuk waktu salat."
        val prayerKey = intent.getStringExtra(PrayerAlarmScheduler.EXTRA_PRAYER_KEY) ?: "prayer"
        val isReminder = intent.getBooleanExtra(PrayerAlarmScheduler.EXTRA_IS_REMINDER, false)
        val soundMode = intent.getStringExtra(PrayerAlarmScheduler.EXTRA_SOUND_MODE) ?: SOUND_MODE_ADHAN
        val channelId = channelIdFor(soundMode)
        val title = if (isReminder) "Pengingat $baseTitle" else baseTitle
        val body = if (isReminder) "Sebentar lagi: $baseBody" else baseBody

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "POST_NOTIFICATIONS denied; cannot show prayer notification id=$id")
            return
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(priorityFor(soundMode))
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setContentIntent(buildContentIntent(context, id, prayerKey))
            .setOnlyAlertOnce(false)
            .addExtras(android.os.Bundle().apply {
                putString("prayerKey", prayerKey)
                putString("soundMode", soundMode)
                putBoolean("isReminder", isReminder)
            })
            .applySoundAndVibration(context, soundMode)
            .build()

        NotificationManagerCompat.from(context).notify(id, notification)
        if (soundMode == SOUND_MODE_ADHAN && !isReminder) {
            startAdhanPlayback(context)
        }
        PrayerAlarmScheduler(context).cancel(id)
        Log.d(TAG, "Displayed prayer notification id=$id prayer=$prayerKey soundMode=$soundMode reminder=$isReminder")
    }

    private fun NotificationCompat.Builder.applySoundAndVibration(
        context: Context,
        soundMode: String,
    ): NotificationCompat.Builder {
        return when (soundMode) {
            SOUND_MODE_SILENT -> setSilent(true).setVibrate(null)
            SOUND_MODE_BEEP -> setDefaults(NotificationCompat.DEFAULT_SOUND).setVibrate(longArrayOf(0, 180))
            else -> setSound(adhanSoundUri(context)).setVibrate(longArrayOf(0, 700, 300, 700))
        }
    }

    private fun startAdhanPlayback(context: Context) {
        val serviceIntent = Intent(context, AdhanPlaybackService::class.java)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (exception: Exception) {
            Log.e(TAG, "Unable to start adhan playback service", exception)
        }
    }

    private fun buildContentIntent(context: Context, id: Int, prayerKey: String): PendingIntent {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent().setPackage(context.packageName)
        launchIntent.putExtra("route", "/schedule")
        launchIntent.putExtra("prayerKey", prayerKey)
        launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP

        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        return PendingIntent.getActivity(context, id + CONTENT_INTENT_OFFSET, launchIntent, flags)
    }

    companion object {
        private const val TAG = "PrayerAlarmReceiver"
        private const val CONTENT_INTENT_OFFSET = 200000
    }
}

const val CHANNEL_ID = "prayer_times_adhan_channel"
const val BEEP_CHANNEL_ID = "prayer_times_beep_channel"
const val SILENT_CHANNEL_ID = "prayer_times_silent_channel"
private const val SOUND_MODE_ADHAN = "adhan"
private const val SOUND_MODE_BEEP = "beep"
private const val SOUND_MODE_SILENT = "silent"

fun ensureNotificationChannel(context: Context) {
    ensureNotificationChannels(context)
}

fun ensureNotificationChannels(context: Context) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

    val alarmAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_ALARM)
        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
        .build()
    val notificationAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
        .build()

    val adhanChannel = NotificationChannel(
        CHANNEL_ID,
        "Prayer Times Adhan",
        NotificationManager.IMPORTANCE_HIGH,
    ).apply {
        description = "Adhan notifications for prayer times"
        enableVibration(true)
        setSound(adhanSoundUri(context), alarmAttributes)
    }

    val beepChannel = NotificationChannel(
        BEEP_CHANNEL_ID,
        "Prayer Times Beep",
        NotificationManager.IMPORTANCE_DEFAULT,
    ).apply {
        description = "Short sound notifications for prayer times"
        enableVibration(true)
        setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI, notificationAttributes)
    }

    val silentChannel = NotificationChannel(
        SILENT_CHANNEL_ID,
        "Prayer Times Silent",
        NotificationManager.IMPORTANCE_LOW,
    ).apply {
        description = "Silent notifications for prayer times"
        enableVibration(false)
        setSound(null, null)
    }

    val manager = context.getSystemService(NotificationManager::class.java)
    manager.createNotificationChannels(listOf(adhanChannel, beepChannel, silentChannel))
}

fun adhanSoundUri(context: Context): Uri {
    return Uri.parse("android.resource://${context.packageName}/raw/adhan")
}

private fun channelIdFor(soundMode: String): String {
    return when (soundMode) {
        SOUND_MODE_BEEP -> BEEP_CHANNEL_ID
        SOUND_MODE_SILENT -> SILENT_CHANNEL_ID
        else -> CHANNEL_ID
    }
}

private fun priorityFor(soundMode: String): Int {
    return when (soundMode) {
        SOUND_MODE_SILENT -> NotificationCompat.PRIORITY_DEFAULT
        SOUND_MODE_BEEP -> NotificationCompat.PRIORITY_HIGH
        else -> NotificationCompat.PRIORITY_MAX
    }
}
