import AVFoundation
import UIKit
import CoreLocation
import Flutter
import UserNotifications
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// Thread identifier of adhan notifications (adhan sound mode, not
  /// reminders). Must match `NotificationService.iosAdhanThreadIdentifier`.
  private static let adhanThreadIdentifier = "solatify.adhan"
  /// A tapped adhan notification older than this does not start the adhan.
  private static let adhanTapWindow: TimeInterval = 15 * 60

  private let adhanPlayer = AdhanPlayer()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self
    registerIosSettingsChannel()
    registerIosPrayerWidgetChannel()
    registerCompassChannel()
    registerAdhanChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // iOS cuts notification sounds at 30 seconds. In the foreground the app
    // can play the whole adhan itself, so the short notification sound is
    // dropped to avoid both playing at once.
    let content = notification.request.content
    let playsFullAdhan = content.threadIdentifier == Self.adhanThreadIdentifier
      && adhanPlayer.play(prayerKey: content.userInfo["payload"] as? String)
    if #available(iOS 14.0, *) {
      completionHandler(playsFullAdhan ? [.banner, .list, .badge] : [.banner, .list, .sound, .badge])
    } else {
      completionHandler(playsFullAdhan ? [.alert, .badge] : [.alert, .sound, .badge])
    }
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // Tapping an adhan notification (from the background or a cold start)
    // plays the full adhan, since the notification sound stops at 30 s.
    let notification = response.notification
    let content = notification.request.content
    if response.actionIdentifier == UNNotificationDefaultActionIdentifier,
       content.threadIdentifier == Self.adhanThreadIdentifier,
       Date().timeIntervalSince(notification.date) <= Self.adhanTapWindow,
       !adhanPlayer.isPlaying {
      _ = adhanPlayer.play(prayerKey: content.userInfo["payload"] as? String)
    }
    // Keeps flutter_local_notifications' tap callback working.
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  private func registerAdhanChannel() {
    guard let registrar = registrar(forPlugin: "SolatifyAdhanPlayer") else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "solatify/ios_adhan",
      binaryMessenger: registrar.messenger()
    )
    adhanPlayer.onStateChanged = { [weak channel] state in
      channel?.invokeMethod("adhanStateChanged", arguments: state)
    }
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      switch call.method {
      case "getState":
        result(self.adhanPlayer.state)
      case "stop":
        self.adhanPlayer.stop()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
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
/// plugin started CoreMotion and a location manager at app launch).
///
/// `trueHeading` is only valid while location updates run, so when location
/// is authorised (prayer times already need it) coarse, kilometre-accuracy
/// updates run alongside the heading; otherwise the heading falls back to
/// magnetic north. Readings the system marks invalid (interference) are
/// reported with a large error so the screen asks for calibration instead of
/// declaring the compass missing.
final class CompassStreamHandler: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var eventSink: FlutterEventSink?
  private var lastHeading: Double?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard CLLocationManager.headingAvailable() else {
      return FlutterError(code: "unavailable", message: "Compass not available on this device", details: nil)
    }
    eventSink = events
    lastHeading = nil
    let manager = CLLocationManager()
    manager.delegate = self
    manager.headingFilter = 1
    manager.headingOrientation = .portrait
    locationManager = manager
    startLocationIfAuthorized(manager)
    manager.startUpdatingHeading()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager?.stopUpdatingHeading()
    locationManager?.stopUpdatingLocation()
    locationManager?.delegate = nil
    locationManager = nil
    eventSink = nil
    return nil
  }

  private func startLocationIfAuthorized(_ manager: CLLocationManager) {
    let status: CLAuthorizationStatus
    if #available(iOS 14.0, *) {
      status = manager.authorizationStatus
    } else {
      status = CLLocationManager.authorizationStatus()
    }
    guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
    manager.desiredAccuracy = kCLLocationAccuracyKilometer
    manager.distanceFilter = 1000
    manager.startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    guard let sink = eventSink else { return }
    guard newHeading.headingAccuracy >= 0 else {
      // Invalid reading (magnetic interference): keep the last direction
      // and flag it as needing calibration.
      let heading = lastHeading ?? newHeading.magneticHeading
      sink(["heading": heading, "accuracy": 999.0])
      return
    }
    let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    lastHeading = heading
    sink([
      "heading": heading,
      "accuracy": newHeading.headingAccuracy,
    ])
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Only needed so trueHeading is valid; the location itself is unused.
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    NSLog("Solatify compass location: \(error.localizedDescription)")
  }

  /// Let iOS show its calibration prompt when the compass is inaccurate.
  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    true
  }
}

/// Plays the bundled full-length adhan (`adhan.mp3`).
///
/// iOS limits notification sounds to 30 seconds, so the notification itself
/// only carries the opening of the adhan. Uses the playback category so the
/// adhan keeps going when the screen locks (UIBackgroundModes audio), and
/// restores the previous session category afterwards so Quran recitation
/// keeps the session it configured.
final class AdhanPlayer: NSObject, AVAudioPlayerDelegate {
  var onStateChanged: (([String: Any]) -> Void)?

  private var player: AVAudioPlayer?
  private var prayerKey: String?
  private var previousCategory: AVAudioSession.Category?
  private var previousMode: AVAudioSession.Mode?
  private var previousOptions: AVAudioSession.CategoryOptions?

  override init() {
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleInterruption(_:)),
      name: AVAudioSession.interruptionNotification,
      object: AVAudioSession.sharedInstance()
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  var isPlaying: Bool { player?.isPlaying ?? false }

  var state: [String: Any] {
    var state: [String: Any] = ["playing": isPlaying]
    if isPlaying, let prayerKey = prayerKey {
      state["prayerKey"] = prayerKey
    }
    return state
  }

  /// Starts the adhan from the beginning. Returns false if it could not be
  /// played, so the caller can fall back to the notification sound.
  @discardableResult
  func play(prayerKey: String?) -> Bool {
    guard let url = Bundle.main.url(forResource: "adhan", withExtension: "mp3") else {
      NSLog("Solatify adhan: adhan.mp3 is missing from the bundle")
      return false
    }

    player?.stop()
    let session = AVAudioSession.sharedInstance()
    do {
      if previousCategory == nil {
        previousCategory = session.category
        previousMode = session.mode
        previousOptions = session.categoryOptions
      }
      try session.setCategory(.playback, mode: .default, options: [])
      try session.setActive(true)

      let newPlayer = try AVAudioPlayer(contentsOf: url)
      newPlayer.delegate = self
      guard newPlayer.play() else {
        NSLog("Solatify adhan: playback did not start")
        finish()
        return false
      }
      player = newPlayer
      self.prayerKey = prayerKey
      onStateChanged?(state)
      return true
    } catch {
      NSLog("Solatify adhan: \(error.localizedDescription)")
      finish()
      return false
    }
  }

  func stop() {
    guard player != nil else { return }
    player?.stop()
    finish()
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    finish()
  }

  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    NSLog("Solatify adhan decode error: \(error?.localizedDescription ?? "unknown")")
    finish()
  }

  /// A call or alarm interrupts the adhan; it is not resumed afterwards.
  @objc private func handleInterruption(_ notification: Notification) {
    guard player != nil,
          let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
          AVAudioSession.InterruptionType(rawValue: rawType) == .began else {
      return
    }
    stop()
  }

  private func finish() {
    player?.delegate = nil
    player = nil
    prayerKey = nil

    let session = AVAudioSession.sharedInstance()
    do {
      if let category = previousCategory {
        try session.setCategory(
          category,
          mode: previousMode ?? .default,
          options: previousOptions ?? []
        )
      }
      // Lets music from other apps resume after the adhan.
      try session.setActive(false, options: .notifyOthersOnDeactivation)
    } catch {
      // Expected while other audio in the app is still running.
      NSLog("Solatify adhan session restore: \(error.localizedDescription)")
    }
    previousCategory = nil
    previousMode = nil
    previousOptions = nil
    onStateChanged?(state)
  }
}
