package com.solatify.app.solatify.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.solatify.app.solatify.R

class AdhanPlaybackService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private var previousAlarmVolume: Int? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(PLAYBACK_NOTIFICATION_ID, buildPlaybackNotification())
        playAdhan()
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        releasePlayer()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun playAdhan() {
        releasePlayer()

        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        previousAlarmVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
        val maxAlarmVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        if (previousAlarmVolume == 0 && maxAlarmVolume > 0) {
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxAlarmVolume / 2, 0)
        }

        val assetFileDescriptor = resources.openRawResourceFd(R.raw.adhan)
        mediaPlayer = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build(),
            )
            setDataSource(
                assetFileDescriptor.fileDescriptor,
                assetFileDescriptor.startOffset,
                assetFileDescriptor.length,
            )
            assetFileDescriptor.close()
            setOnCompletionListener {
                stopSelf()
            }
            setOnErrorListener { _, what, extra ->
                Log.e(TAG, "Adhan playback failed what=$what extra=$extra")
                stopSelf()
                true
            }
            prepare()
            start()
            Log.d(TAG, "Adhan playback started")
        }
    }

    private fun releasePlayer() {
        mediaPlayer?.run {
            try {
                if (isPlaying) stop()
            } catch (exception: IllegalStateException) {
                Log.w(TAG, "MediaPlayer already stopped", exception)
            }
            release()
        }
        mediaPlayer = null

        val originalVolume = previousAlarmVolume
        if (originalVolume != null) {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, originalVolume, 0)
        }
        previousAlarmVolume = null
    }

    private fun buildPlaybackNotification(): Notification {
        ensurePlaybackChannel()
        return NotificationCompat.Builder(this, PLAYBACK_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Solatify")
            .setContentText("Playing adhan")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    private fun ensurePlaybackChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            PLAYBACK_CHANNEL_ID,
            "Adhan Playback",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Keeps adhan audio playing at prayer time"
            setSound(null, null)
            enableVibration(false)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    companion object {
        private const val TAG = "AdhanPlaybackService"
        private const val PLAYBACK_CHANNEL_ID = "adhan_playback_service_channel"
        private const val PLAYBACK_NOTIFICATION_ID = 99001
    }
}
