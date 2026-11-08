package com.solatify.app.solatify.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
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
import com.solatify.app.solatify.R

class AdhanPlaybackService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private var isEnglish = false
    private var focusRequest: AudioFocusRequest? = null

    private val audioManager: AudioManager?
        get() = getSystemService(Context.AUDIO_SERVICE) as? AudioManager

    private val alarmAttributes: AudioAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_ALARM)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
        .build()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP_ADHAN) {
            releasePlayer()
            stopSelf()
            return START_NOT_STICKY
        }

        isEnglish = intent?.getBooleanExtra(EXTRA_IS_ENGLISH, false) ?: false
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

        // The alarm volume is the user's choice; it is no longer raised
        // silently when muted. Any failure stops the service instead of
        // crashing the app in the background.
        try {
            startPlayer()
        } catch (exception: Exception) {
            Log.e(TAG, "Unable to play adhan", exception)
            releasePlayer()
            stopSelf()
        }
    }

    /** Pauses other audio (Quran recitation, music) for the adhan; they may
     *  resume when focus is abandoned after it ends. */
    private fun requestAudioFocus() {
        val manager = audioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(alarmAttributes)
                .build()
            focusRequest = request
            manager.requestAudioFocus(request)
        } else {
            @Suppress("DEPRECATION")
            manager.requestAudioFocus(null, AudioManager.STREAM_ALARM, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
        }
    }

    private fun abandonAudioFocus() {
        val manager = audioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest?.let { manager.abandonAudioFocusRequest(it) }
            focusRequest = null
        } else {
            @Suppress("DEPRECATION")
            manager.abandonAudioFocus(null)
        }
    }

    private fun startPlayer() {
        val assetFileDescriptor = resources.openRawResourceFd(R.raw.adhan)
        requestAudioFocus()
        mediaPlayer = MediaPlayer().apply {
            setAudioAttributes(alarmAttributes)
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
        abandonAudioFocus()
    }

    private fun buildPlaybackNotification(): Notification {
        ensurePlaybackChannel()
        val stopPendingIntent = stopIntent(this)

        return NotificationCompat.Builder(this, PLAYBACK_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_solatify)
            .setContentTitle("Solatify")
            .setContentText(if (isEnglish) "Adhan is playing" else "Adzan sedang diputar")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setOngoing(true)
            .setSilent(true)
            .addAction(
                R.drawable.ic_stat_solatify,
                if (isEnglish) "Stop" else "Berhenti",
                stopPendingIntent,
            )
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
        /** Stops the adhan; used by the stop action and by dismissing the
         *  prayer notification. */
        fun stopIntent(context: Context): PendingIntent {
            val intent = Intent(context, AdhanPlaybackService::class.java).apply {
                action = ACTION_STOP_ADHAN
            }
            val immutable =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
            return PendingIntent.getService(
                context,
                STOP_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or immutable,
            )
        }

        const val EXTRA_IS_ENGLISH = "isEnglish"
        private const val TAG = "AdhanPlaybackService"
        private const val ACTION_STOP_ADHAN = "com.solatify.app.solatify.STOP_ADHAN"
        private const val PLAYBACK_CHANNEL_ID = "adhan_playback_service_channel"
        private const val PLAYBACK_NOTIFICATION_ID = 99001
        private const val STOP_REQUEST_CODE = 99002
    }
}
