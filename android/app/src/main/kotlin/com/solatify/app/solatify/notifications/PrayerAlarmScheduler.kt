package com.solatify.app.solatify.notifications

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

class PrayerAlarmScheduler(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun canScheduleExactAlarms(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()
    }

    fun schedule(alarm: PrayerAlarm): Boolean {
        if (alarm.scheduledAtMillis <= System.currentTimeMillis()) {
            Log.w(TAG, "Skipping past prayer alarm id=${alarm.id} at=${alarm.scheduledAtMillis}")
            removeStoredAlarm(alarm.id)
            cancel(alarm.id)
            return false
        }

        ensureNotificationChannel(context)
        val pendingIntent = buildPendingIntent(alarm, PendingIntent.FLAG_UPDATE_CURRENT)
        val showIntent = buildShowIntent(alarm)

        try {
            if (canScheduleExactAlarms()) {
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(alarm.scheduledAtMillis, showIntent),
                    pendingIntent,
                )
            } else {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    alarm.scheduledAtMillis,
                    pendingIntent
                )
            }
            storeAlarm(alarm)
            Log.d(TAG, "Scheduled prayer alarm id=${alarm.id} at=${alarm.scheduledAtMillis} exact=${canScheduleExactAlarms()}")
            return true
        } catch (exception: SecurityException) {
            Log.e(TAG, "Unable to schedule prayer alarm id=${alarm.id}", exception)
            return false
        }
    }

    fun cancel(id: Int) {
        val pendingIntent = buildPendingIntentForId(id, PendingIntent.FLAG_NO_CREATE)
        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }
        removeStoredAlarm(id)
    }

    fun cancelAll() {
        getStoredAlarms().forEach { cancel(it.id) }
        preferences.edit().remove(KEY_ALARMS).apply()
    }

    fun rescheduleStoredAlarms(): Int {
        val now = System.currentTimeMillis()
        val futureAlarms = getStoredAlarms().filter { it.scheduledAtMillis > now }
        preferences.edit().remove(KEY_ALARMS).apply()
        futureAlarms.forEach { schedule(it) }
        return futureAlarms.size
    }

    fun getPendingIds(): List<Int> {
        val now = System.currentTimeMillis()
        return getStoredAlarms()
            .filter { it.scheduledAtMillis > now }
            .map { it.id }
            .sorted()
    }

    private fun buildPendingIntent(alarm: PrayerAlarm, flags: Int): PendingIntent {
        val intent = Intent(context, PrayerAlarmReceiver::class.java).apply {
            action = ACTION_PRAYER_ALARM
            putExtra(EXTRA_ID, alarm.id)
            putExtra(EXTRA_PRAYER_KEY, alarm.prayerKey)
            putExtra(EXTRA_TITLE, alarm.title)
            putExtra(EXTRA_BODY, alarm.body)
            putExtra(EXTRA_SCHEDULED_AT, alarm.scheduledAtMillis)
            putExtra(EXTRA_IS_REMINDER, alarm.isReminder)
            putExtra(EXTRA_SOUND_MODE, alarm.soundMode)
        }
        return PendingIntent.getBroadcast(context, alarm.id, intent, flags or immutableFlag())
    }

    private fun buildPendingIntentForId(id: Int, flags: Int): PendingIntent? {
        val intent = Intent(context, PrayerAlarmReceiver::class.java).apply {
            action = ACTION_PRAYER_ALARM
        }
        return PendingIntent.getBroadcast(context, id, intent, flags or immutableFlag())
    }

    private fun buildShowIntent(alarm: PrayerAlarm): PendingIntent {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent().setPackage(context.packageName)
        launchIntent.putExtra(EXTRA_PRAYER_KEY, alarm.prayerKey)
        return PendingIntent.getActivity(
            context,
            alarm.id + SHOW_INTENT_OFFSET,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )
    }

    private fun storeAlarm(alarm: PrayerAlarm) {
        val alarms = getStoredAlarms()
            .filterNot { it.id == alarm.id }
            .plus(alarm)
            .sortedBy { it.scheduledAtMillis }
        val array = JSONArray()
        alarms.forEach { array.put(it.toJson()) }
        preferences.edit().putString(KEY_ALARMS, array.toString()).apply()
    }

    private fun removeStoredAlarm(id: Int) {
        val alarms = getStoredAlarms().filterNot { it.id == id }
        val array = JSONArray()
        alarms.forEach { array.put(it.toJson()) }
        preferences.edit().putString(KEY_ALARMS, array.toString()).apply()
    }

    private fun getStoredAlarms(): List<PrayerAlarm> {
        val raw = preferences.getString(KEY_ALARMS, null) ?: return emptyList()
        return try {
            val array = JSONArray(raw)
            List(array.length()) { index -> PrayerAlarm.fromJson(array.getJSONObject(index)) }
        } catch (exception: Exception) {
            Log.e(TAG, "Unable to parse stored prayer alarms", exception)
            emptyList()
        }
    }

    private fun immutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
    }

    fun exactAlarmSettingsIntent(): Intent? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = android.net.Uri.parse("package:${context.packageName}")
            }
        } else {
            null
        }
    }

    companion object {
        private const val TAG = "PrayerAlarmScheduler"
        private const val PREFS_NAME = "solatify_prayer_alarms"
        private const val KEY_ALARMS = "alarms"
        private const val SHOW_INTENT_OFFSET = 100000
        const val ACTION_PRAYER_ALARM = "com.solatify.app.solatify.PRAYER_ALARM"
        const val EXTRA_ID = "id"
        const val EXTRA_PRAYER_KEY = "prayerKey"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_SCHEDULED_AT = "scheduledAtMillis"
        const val EXTRA_IS_REMINDER = "isReminder"
        const val EXTRA_SOUND_MODE = "soundMode"
    }
}

data class PrayerAlarm(
    val id: Int,
    val prayerKey: String,
    val title: String,
    val body: String,
    val scheduledAtMillis: Long,
    val isReminder: Boolean = false,
    val soundMode: String = "adhan",
) {
    fun toJson(): JSONObject {
        return JSONObject()
            .put("id", id)
            .put("prayerKey", prayerKey)
            .put("title", title)
            .put("body", body)
            .put("scheduledAtMillis", scheduledAtMillis)
            .put("isReminder", isReminder)
            .put("soundMode", soundMode)
    }

    companion object {
        fun fromJson(json: JSONObject): PrayerAlarm {
            return PrayerAlarm(
                id = json.getInt("id"),
                prayerKey = json.getString("prayerKey"),
                title = json.getString("title"),
                body = json.getString("body"),
                scheduledAtMillis = json.getLong("scheduledAtMillis"),
                isReminder = json.optBoolean("isReminder", false),
                soundMode = json.optString("soundMode", "adhan"),
            )
        }
    }
}
