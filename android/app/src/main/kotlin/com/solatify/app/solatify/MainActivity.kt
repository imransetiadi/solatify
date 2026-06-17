package com.solatify.app.solatify

import com.solatify.app.solatify.notifications.PrayerAlarm
import com.solatify.app.solatify.notifications.PrayerAlarmScheduler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val scheduler = PrayerAlarmScheduler(applicationContext)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "solatify/android_prayer_alarms",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "schedulePrayerAlarm" -> {
                    val id = call.argument<Int>("id")
                    val prayerKey = call.argument<String>("prayerKey")
                    val title = call.argument<String>("title")
                    val body = call.argument<String>("body")
                    val scheduledAtMillis = call.argument<Long>("scheduledAtMillis")

                    if (id == null || prayerKey == null || title == null || body == null || scheduledAtMillis == null) {
                        result.error("invalid_arguments", "Missing prayer alarm fields", null)
                        return@setMethodCallHandler
                    }

                    result.success(
                        scheduler.schedule(
                            PrayerAlarm(
                                id = id,
                                prayerKey = prayerKey,
                                title = title,
                                body = body,
                                scheduledAtMillis = scheduledAtMillis,
                            ),
                        ),
                    )
                }

                "cancelPrayerAlarm" -> {
                    val id = call.argument<Int>("id")
                    if (id == null) {
                        result.error("invalid_arguments", "Missing alarm id", null)
                        return@setMethodCallHandler
                    }
                    scheduler.cancel(id)
                    result.success(null)
                }

                "cancelAllPrayerAlarms" -> {
                    scheduler.cancelAll()
                    result.success(null)
                }

                "getPendingPrayerAlarmIds" -> {
                    result.success(scheduler.getPendingIds())
                }

                "canScheduleExactAlarms" -> {
                    result.success(scheduler.canScheduleExactAlarms())
                }

                "openExactAlarmSettings" -> {
                    val intent = scheduler.exactAlarmSettingsIntent()
                    if (intent == null) {
                        result.success(false)
                    } else {
                        startActivity(intent)
                        result.success(true)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
