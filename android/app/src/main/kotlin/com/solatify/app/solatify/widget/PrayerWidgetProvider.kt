package com.solatify.app.solatify.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import com.solatify.app.solatify.MainActivity
import com.solatify.app.solatify.R

class PrayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        // Last widget removed: stop waking up at prayer times.
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        alarmManager?.cancel(refreshIntent(context))
    }

    companion object {
        fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray,
        ) {
            if (appWidgetIds.isEmpty()) return
            val data = PrayerWidgetStore.read(context)
            val next = data.nextSlot(System.currentTimeMillis())
            for (appWidgetId in appWidgetIds) {
                updateWidget(context, appWidgetManager, appWidgetId, data, next)
            }
            scheduleRefreshAt(context, next)
        }

        private fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            data: PrayerWidgetData,
            next: PrayerSlot?,
        ) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                setTextViewText(R.id.widget_next_prayer_name, next?.name ?: data.nextPrayerName)
                setTextViewText(R.id.widget_next_prayer_time, next?.timeLabel ?: data.nextPrayerTimeLabel)
                setTextViewText(R.id.widget_location, data.locationLabel)
                setTextViewText(R.id.widget_hijri, data.hijriLabel)
                setOnClickPendingIntent(R.id.widget_root, openAppIntent(context))

                if (next != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    // Chronometer base is on the elapsedRealtime clock.
                    val remaining = next.epochMillis - System.currentTimeMillis()
                    setChronometer(
                        R.id.widget_countdown,
                        SystemClock.elapsedRealtime() + remaining,
                        null,
                        true,
                    )
                    setChronometerCountDown(R.id.widget_countdown, true)
                } else {
                    // No live countdown available: show a static label instead.
                    setChronometer(
                        R.id.widget_countdown,
                        SystemClock.elapsedRealtime(),
                        next?.timeLabel ?: data.countdownLabel,
                        false,
                    )
                }
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        /**
         * Wakes the widget when the next prayer starts so it moves on to the
         * following prayer while the app is closed (instead of counting into
         * negative time until the next 30-minute system update).
         */
        private fun scheduleRefreshAt(context: Context, next: PrayerSlot?) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val pendingIntent = refreshIntent(context)
            if (next == null) {
                alarmManager.cancel(pendingIntent)
                return
            }
            val triggerAt = next.epochMillis + 1_000
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC, triggerAt, pendingIntent)
                } else {
                    alarmManager.set(AlarmManager.RTC, triggerAt, pendingIntent)
                }
            } catch (error: SecurityException) {
                // Inexact alarms need no permission; ignore unexpected OEM limits.
            }
        }

        private fun refreshIntent(context: Context): PendingIntent {
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(ComponentName(context, PrayerWidgetProvider::class.java))
            val intent = Intent(context, PrayerWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            return PendingIntent.getBroadcast(context, 1, intent, immutableUpdateFlags())
        }

        private fun openAppIntent(context: Context): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            return PendingIntent.getActivity(context, 0, intent, immutableUpdateFlags())
        }

        private fun immutableUpdateFlags(): Int =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
    }
}
