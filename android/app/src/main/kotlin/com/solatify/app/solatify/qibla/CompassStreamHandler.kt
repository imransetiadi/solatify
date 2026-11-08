package com.solatify.app.solatify.qibla

import android.content.Context
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

/**
 * Streams the device heading (degrees from TRUE north) for the Qibla screen.
 *
 * Replaces flutter_compass_v2, which reported magnetic north on Android and
 * therefore pointed the Qibla off by the local magnetic declination (about 1°
 * in Indonesia, over 10° in parts of Europe and North America). Sensors are
 * only registered while Dart is listening.
 */
class CompassStreamHandler(context: Context) : EventChannel.StreamHandler, SensorEventListener {
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
    private var eventSink: EventChannel.EventSink? = null
    private var declinationDegrees = 0f
    private var accuracyDegrees: Double? = null
    private var lastSentHeading: Double? = null
    private val rotationMatrix = FloatArray(9)
    private val orientation = FloatArray(3)

    // Fallback for phones without a gyroscope (no rotation-vector sensors):
    // low-pass filtered accelerometer + magnetometer readings.
    private var useRawSensors = false
    private val gravity = FloatArray(3)
    private val geomagnetic = FloatArray(3)
    private var hasGravity = false
    private var hasGeomagnetic = false

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val manager = sensorManager
        // Prefer the fused rotation vector; budget phones without a gyroscope
        // often still have the geomagnetic one, or at least an accelerometer
        // and a magnetometer.
        val rotation = manager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            ?: manager?.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
        val accelerometer = manager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        val magnetometer = manager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
        if (manager == null || (rotation == null && (accelerometer == null || magnetometer == null))) {
            events.error("unavailable", "Compass not available on this device", null)
            return
        }
        declinationDegrees = declinationFor(arguments)
        eventSink = events
        lastSentHeading = null
        hasGravity = false
        hasGeomagnetic = false
        if (rotation != null) {
            useRawSensors = false
            manager.registerListener(this, rotation, SensorManager.SENSOR_DELAY_UI)
        } else {
            useRawSensors = true
            manager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_UI)
            manager.registerListener(this, magnetometer, SensorManager.SENSOR_DELAY_UI)
        }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager?.unregisterListener(this)
        eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        val sink = eventSink ?: return
        if (useRawSensors) {
            when (event.sensor.type) {
                Sensor.TYPE_ACCELEROMETER -> {
                    lowPass(event.values, gravity, hasGravity)
                    hasGravity = true
                }
                Sensor.TYPE_MAGNETIC_FIELD -> {
                    lowPass(event.values, geomagnetic, hasGeomagnetic)
                    hasGeomagnetic = true
                }
                else -> return
            }
            if (!hasGravity || !hasGeomagnetic) return
            if (!SensorManager.getRotationMatrix(rotationMatrix, null, gravity, geomagnetic)) return
        } else {
            SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
        }
        SensorManager.getOrientation(rotationMatrix, orientation)
        val magnetic = Math.toDegrees(orientation[0].toDouble())
        val heading = ((magnetic + declinationDegrees) % 360 + 360) % 360

        // Skip tiny changes to avoid flooding the UI with redundant frames.
        val previous = lastSentHeading
        if (previous != null && angularDistance(previous, heading) < 0.5) return
        lastSentHeading = heading

        sink.success(mapOf("heading" to heading, "accuracy" to accuracyDegrees))
    }

    override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
        accuracyDegrees = when (accuracy) {
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> 5.0
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> 15.0
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> 30.0
            else -> 45.0 // Unreliable: the phone should be calibrated.
        }
    }

    private fun lowPass(input: FloatArray, output: FloatArray, initialized: Boolean) {
        if (!initialized) {
            input.copyInto(output, endIndex = 3)
            return
        }
        for (i in 0 until 3) {
            output[i] = output[i] + LOW_PASS_ALPHA * (input[i] - output[i])
        }
    }

    private fun declinationFor(arguments: Any?): Float {
        val args = arguments as? Map<*, *> ?: return 0f
        val latitude = (args["latitude"] as? Number)?.toFloat() ?: return 0f
        val longitude = (args["longitude"] as? Number)?.toFloat() ?: return 0f
        return GeomagneticField(latitude, longitude, 0f, System.currentTimeMillis()).declination
    }

    private fun angularDistance(a: Double, b: Double): Double {
        val diff = Math.abs(a - b) % 360
        return if (diff > 180) 360 - diff else diff
    }

    private companion object {
        /** Smoothing for the raw-sensor fallback (lower = smoother). */
        const val LOW_PASS_ALPHA = 0.15f
    }
}
