package com.solatify.app.solatify.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
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
        if (intent?.action == ACTION_STOP_ADHAN) {
            releasePlayer()
            stopSelf()
            return START_NOT_STICKY
        }

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
        val stopIntent = Intent(this, AdhanPlaybackService::class.java).apply {
            action = ACTION_STOP_ADHAN
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            STOP_REQUEST_CODE,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )

        return NotificationCompat.Builder(this, PLAYBACK_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Solatify")
            .setContentText("Playing adhan")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setOngoing(true)
            .setSilent(true)
            .addAction(R.mipmap.ic_launcher, "Berhenti", stopPendingIntent)
            .build()
    }

    private fun immutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
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
        private const val ACTION_STOP_ADHAN = "com.solatify.app.solatify.STOP_ADHAN"
        private const val PLAYBACK_CHANNEL_ID = "adhan_playback_service_channel"
        private const val PLAYBACK_NOTIFICATION_ID = 99001
        private const val STOP_REQUEST_CODE = 99002
    }
}
