import UIKit
import CoreLocation
import Flutter
import UserNotifications
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self
    registerIosSettingsChannel()
    registerIosPrayerWidgetChannel()
    registerCompassChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  private func registerIosSettingsChannel() {
    guard let registrar = registrar(forPlugin: "SolatifyIosSettings") else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "solatify/ios_settings",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "openNotificationSettings":
        self.openNotificationSettings(result: result)
      case "requestNotificationPermissions":
        self.requestNotificationPermissions(result: result)
      case "areNotificationsEnabled":
        self.areNotificationsEnabled(result: result)
      case "showTestNotification":
        self.showTestNotification(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // Kept alive for the app's lifetime; it only runs the compass while the
  // Dart side is listening.
  private let compassStreamHandler = CompassStreamHandler()

  private func registerCompassChannel() {
    guard let registrar = registrar(forPlugin: "SolatifyCompass") else {
      return
    }
    FlutterEventChannel(
      name: "solatify/compass",
      binaryMessenger: registrar.messenger()
    ).setStreamHandler(compassStreamHandler)
  }

  private func registerIosPrayerWidgetChannel() {
    guard let registrar = registrar(forPlugin: "SolatifyIosPrayerWidget") else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "solatify/ios_prayer_widget",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "syncPrayerWidget":
        self.syncPrayerWidget(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func syncPrayerWidget(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let payload = call.arguments as? [String: String],
          let defaults = UserDefaults(suiteName: "group.com.solatify.app.solatify") else {
      result(false)
      return
    }

    defaults.set(payload["nextPrayerName"] ?? "-", forKey: "nextPrayerName")
    defaults.set(payload["nextPrayerTimeLabel"] ?? "--:--", forKey: "nextPrayerTimeLabel")
    defaults.set(payload["countdownLabel"] ?? "--:--", forKey: "countdownLabel")
    defaults.set(payload["locationLabel"] ?? "Solatify", forKey: "locationLabel")
    defaults.set(payload["hijriLabel"] ?? "Jadwal salat", forKey: "hijriLabel")
    defaults.set(payload["schedule"] ?? "", forKey: "schedule")

    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadTimelines(ofKind: "SolatifyPrayerWidget")
    }
    result(true)
  }

  private func requestNotificationPermissions(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error = error {
        NSLog("Solatify iOS notification permission error: \(error.localizedDescription)")
      }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
        result(granted)
      }
    }
  }

  private func areNotificationsEnabled(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      result(self.isNotificationAuthorized(settings.authorizationStatus))
    }
  }

  private func showTestNotification(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      guard self.isNotificationAuthorized(settings.authorizationStatus) else {
        result(false)
        return
      }

      let content = UNMutableNotificationContent()
      content.title = "Tes Notifikasi Solatify"
      content.body = "Jika notifikasi ini muncul, pengingat salat siap digunakan."
      content.sound = .default

      let request = UNNotificationRequest(
        identifier: "solatify-ios-test-\(Int(Date().timeIntervalSince1970))",
        content: content,
        trigger: nil
      )

      UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
          NSLog("Solatify iOS test notification error: \(error.localizedDescription)")
          result(false)
          return
        }
        result(true)
      }
    }
  }

  private func isNotificationAuthorized(_ status: UNAuthorizationStatus) -> Bool {
    if status == .authorized || status == .provisional {
      return true
    }
    if #available(iOS 14.0, *) {
      return status == .ephemeral
    }
    return false
  }

  private func openNotificationSettings(result: @escaping FlutterResult) {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      result(false)
      return
    }

    DispatchQueue.main.async {
      UIApplication.shared.open(url, options: [:]) { success in
        result(success)
      }
    }
  }
}

/// Streams the device heading for the Qibla screen.
///
/// Replaces flutter_compass_v2: nothing is created until Dart listens (the
/// plugin started CoreMotion and a location manager at app launch), and the
/// heading falls back to magnetic north when true north is unavailable
/// instead of sending -1.
final class CompassStreamHandler: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var eventSink: FlutterEventSink?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard CLLocationManager.headingAvailable() else {
      return FlutterError(code: "unavailable", message: "Compass not available on this device", details: nil)
    }
    eventSink = events
    let manager = CLLocationManager()
    manager.delegate = self
    manager.headingFilter = 1
    manager.headingOrientation = .portrait
    locationManager = manager
    manager.startUpdatingHeading()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager?.stopUpdatingHeading()
    locationManager?.delegate = nil
    locationManager = nil
    eventSink = nil
    return nil
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    // A negative accuracy means the reading is invalid (e.g. interference).
    guard newHeading.headingAccuracy >= 0 else { return }
    let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    eventSink?([
      "heading": heading,
      "accuracy": newHeading.headingAccuracy,
    ])
  }

  /// Let iOS show its calibration prompt when the compass is inaccurate.
  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    true
  }
}
