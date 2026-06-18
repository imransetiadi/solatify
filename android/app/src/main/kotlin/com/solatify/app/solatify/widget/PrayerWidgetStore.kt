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

    fun save(context: Context, data: Map<String, String>) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(NEXT_PRAYER_NAME, data[NEXT_PRAYER_NAME] ?: "-")
            .putString(NEXT_PRAYER_TIME_LABEL, data[NEXT_PRAYER_TIME_LABEL] ?: "--:--")
            .putString(COUNTDOWN_LABEL, data[COUNTDOWN_LABEL] ?: "--:--")
            .putString(LOCATION_LABEL, data[LOCATION_LABEL] ?: "Solatify")
            .putString(HIJRI_LABEL, data[HIJRI_LABEL] ?: "Jadwal salat")
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
)
