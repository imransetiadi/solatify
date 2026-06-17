package com.solatify.app.solatify.notifications

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.solatify.app.solatify.R

class AdhanPlaybackService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP_ADHAN) {
            stopPlayback()
            stopSelf()
            return START_NOT_STICKY
        }

        val notificationId = intent?.getIntExtra(PrayerAlarmScheduler.EXTRA_ID, DEFAULT_NOTIFICATION_ID)
            ?: DEFAULT_NOTIFICATION_ID
        val prayerKey = intent?.getStringExtra(PrayerAlarmScheduler.EXTRA_PRAYER_KEY) ?: "prayer"
        val title = intent?.getStringExtra(PrayerAlarmScheduler.EXTRA_TITLE) ?: "Waktu Salat"
        val body = intent?.getStringExtra(PrayerAlarmScheduler.EXTRA_BODY) ?: "Telah masuk waktu salat."

        ensureNotificationChannel(this)
        startForeground(notificationId, buildNotification(notificationId, title, body, prayerKey))
        playAdhan(notificationId)
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopPlayback()
        super.onDestroy()
    }

    private fun playAdhan(notificationId: Int) {
        stopPlayback()
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        requestAudioFocus()

        mediaPlayer = MediaPlayer.create(this, R.raw.adhan)?.apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build(),
            )
            isLooping = false
            setOnCompletionListener {
                NotificationManagerCompat.from(this@AdhanPlaybackService).cancel(notificationId)
                stopSelf()
            }
            setOnErrorListener { _, what, extra ->
                Log.e(TAG, "Adhan playback error what=$what extra=$extra")
                stopSelf()
                true
            }
            start()
        }

        if (mediaPlayer == null) {
            Log.e(TAG, "Unable to create MediaPlayer for adhan")
            stopSelf()
        }
    }

    private fun requestAudioFocus() {
        val manager = audioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build(),
                )
                .build()
            focusRequest = request
            manager.requestAudioFocus(request)
        } else {
            @Suppress("DEPRECATION")
            manager.requestAudioFocus(
                null,
                AudioManager.STREAM_ALARM,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK,
            )
        }
    }

    private fun stopPlayback() {
        mediaPlayer?.run {
            if (isPlaying) stop()
            release()
        }
        mediaPlayer = null

        val manager = audioManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest?.let { manager?.abandonAudioFocusRequest(it) }
        } else {
            @Suppress("DEPRECATION")
            manager?.abandonAudioFocus(null)
        }
        focusRequest = null
    }

    private fun buildNotification(
        notificationId: Int,
        title: String,
        body: String,
        prayerKey: String,
    ): Notification {
        val stopIntent = Intent(this, AdhanPlaybackService::class.java).apply {
            action = ACTION_STOP_ADHAN
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            notificationId + STOP_INTENT_OFFSET,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent().setPackage(packageName)
        launchIntent.putExtra(PrayerAlarmScheduler.EXTRA_PRAYER_KEY, prayerKey)
        val contentIntent = PendingIntent.getActivity(
            this,
            notificationId,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(contentIntent)
            .addAction(R.drawable.launch_background, "Stop", stopPendingIntent)
            .build()
    }

    private fun immutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
    }

    companion object {
        private const val TAG = "AdhanPlaybackService"
        private const val DEFAULT_NOTIFICATION_ID = 7000
        private const val STOP_INTENT_OFFSET = 200000
        const val ACTION_PLAY_ADHAN = "com.solatify.app.solatify.PLAY_ADHAN"
        const val ACTION_STOP_ADHAN = "com.solatify.app.solatify.STOP_ADHAN"
    }
}
