package com.solatify.app.solatify

import com.solatify.app.solatify.notifications.PrayerAlarm
import com.solatify.app.solatify.notifications.PrayerAlarmScheduler
import com.solatify.app.solatify.widget.PrayerWidgetStore
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
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
                    val isReminder = call.argument<Boolean>("isReminder") ?: false
                    val soundMode = call.argument<String>("soundMode") ?: "adhan"

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
                                isReminder = isReminder,
                                soundMode = soundMode,
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

                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }

                "openBatteryOptimizationSettings" -> {
                    result.success(openBatteryOptimizationSettings())
                }

                "openNotificationSettings" -> {
                    result.success(openNotificationSettings())
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "solatify/android_prayer_widget",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncPrayerWidget" -> {
                    @Suppress("UNCHECKED_CAST")
                    val payload = call.arguments as? Map<String, String>
                    if (payload == null) {
                        result.error("invalid_arguments", "Missing prayer widget payload", null)
                        return@setMethodCallHandler
                    }
                    PrayerWidgetStore.save(applicationContext, payload)
                    PrayerWidgetStore.refreshWidgets(applicationContext)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(packageName)
    }

    private fun openBatteryOptimizationSettings(): Boolean {
        return try {
            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                }
            } else {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                }
            }
            startActivity(intent)
            true
        } catch (exception: Exception) {
            val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(fallback)
            true
        }
    }

    private fun openNotificationSettings(): Boolean {
        return try {
            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
            } else {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                }
            }
            startActivity(intent)
            true
        } catch (exception: Exception) {
            val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(fallback)
            true
        }
    }
}
