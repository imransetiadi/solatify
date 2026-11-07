package com.solatify.app.solatify.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context

object PrayerWidgetStore {
    private const val PREFS_NAME = "solatify_prayer_widget"
    private const val NEXT_PRAYER_NAME = "nextPrayerName"
    private const val NEXT_PRAYER_TIME_LABEL = "nextPrayerTimeLabel"
    private const val COUNTDOWN_LABEL = "countdownLabel"
    private const val LOCATION_LABEL = "locationLabel"
    private const val HIJRI_LABEL = "hijriLabel"
    private const val SCHEDULE = "schedule"

    fun save(context: Context, data: Map<String, String>) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(NEXT_PRAYER_NAME, data[NEXT_PRAYER_NAME] ?: "-")
            .putString(NEXT_PRAYER_TIME_LABEL, data[NEXT_PRAYER_TIME_LABEL] ?: "--:--")
            .putString(COUNTDOWN_LABEL, data[COUNTDOWN_LABEL] ?: "--:--")
            .putString(LOCATION_LABEL, data[LOCATION_LABEL] ?: "Solatify")
            .putString(HIJRI_LABEL, data[HIJRI_LABEL] ?: "Jadwal salat")
            .putString(SCHEDULE, data[SCHEDULE] ?: "")
            .apply()
    }

    fun read(context: Context): PrayerWidgetData {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return PrayerWidgetData(
            nextPrayerName = prefs.getString(NEXT_PRAYER_NAME, "-") ?: "-",
            nextPrayerTimeLabel = prefs.getString(NEXT_PRAYER_TIME_LABEL, "--:--") ?: "--:--",
            countdownLabel = prefs.getString(COUNTDOWN_LABEL, "--:--") ?: "--:--",
            locationLabel = prefs.getString(LOCATION_LABEL, "Solatify") ?: "Solatify",
            hijriLabel = prefs.getString(HIJRI_LABEL, "Jadwal salat") ?: "Jadwal salat",
            slots = PrayerSlot.parse(prefs.getString(SCHEDULE, "")),
        )
    }

    fun refreshWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, PrayerWidgetProvider::class.java)
        val ids = appWidgetManager.getAppWidgetIds(component)
        PrayerWidgetProvider.updateWidgets(context, appWidgetManager, ids)
    }
}

data class PrayerWidgetData(
    val nextPrayerName: String,
    val nextPrayerTimeLabel: String,
    val countdownLabel: String,
    val locationLabel: String,
    val hijriLabel: String,
    val slots: List<PrayerSlot>,
) {
    /** The first prayer after [nowMillis], or null once the schedule ran out. */
    fun nextSlot(nowMillis: Long): PrayerSlot? = slots.firstOrNull { it.epochMillis > nowMillis }
}

/** One prayer synced by the app: `name|epochMillis|HH:mm`, entries joined by `;`. */
data class PrayerSlot(
    val name: String,
    val epochMillis: Long,
    val timeLabel: String,
) {
    companion object {
        fun parse(raw: String?): List<PrayerSlot> {
            if (raw.isNullOrEmpty()) return emptyList()
            return raw.split(";").mapNotNull { entry ->
                val parts = entry.split("|")
                val millis = parts.getOrNull(1)?.toLongOrNull()
                if (parts.size != 3 || millis == null) null else PrayerSlot(parts[0], millis, parts[2])
            }.sortedBy { it.epochMillis }
        }
    }
}
