package com.solatify.app.solatify.notifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class PrayerAlarmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED &&
            action != "android.intent.action.QUICKBOOT_POWERON" &&
            action != "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            return
        }

        val count = PrayerAlarmScheduler(context).rescheduleStoredAlarms()
        Log.d(TAG, "Rescheduled $count prayer alarms after $action")
    }

    companion object {
        private const val TAG = "PrayerAlarmBootReceiver"
    }
}
