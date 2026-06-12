import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var notificationChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self
    copyAdhanSoundsToLibrary()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.setupNotificationChannelFromConnectedScenes()
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupNotificationChannelFromConnectedScenes() {
    for scene in UIApplication.shared.connectedScenes {
      guard
        let windowScene = scene as? UIWindowScene,
        let controller = windowScene.windows.first(where: { $0.rootViewController is FlutterViewController })?.rootViewController as? FlutterViewController
      else { continue }
      setupNotificationChannel(controller: controller)
      return
    }
    NSLog("SolatifyNativeNotification: FlutterViewController not ready")
  }

  func setupNotificationChannel(controller: FlutterViewController) {
    if notificationChannel != nil { return }

    let channel = FlutterMethodChannel(
      name: "solatify/notifications",
      binaryMessenger: controller.binaryMessenger
    )
    notificationChannel = channel
    NSLog("SolatifyNativeNotification: channel registered")

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      NSLog("SolatifyNativeNotification: received method \(call.method)")
      switch call.method {
      case "schedulePrayerNotifications":
        self.schedulePrayerNotifications(call: call, result: result)
      case "scheduleTestAdhanNotification":
        self.scheduleTestAdhanNotification(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func schedulePrayerNotifications(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "bad_args", message: "Missing arguments", details: nil))
      return
    }

    let enabled = args["notificationEnabled"] as? Bool ?? false
    let playSound = args["playSound"] as? Bool ?? false
    let soundName = args["soundName"] as? String
    let notifications = args["notifications"] as? [[String: Any]] ?? []
    let center = UNUserNotificationCenter.current()
    NSLog("SolatifyNativeNotification: schedulePrayerNotifications enabled=\(enabled) playSound=\(playSound) sound=\(soundName ?? "default") count=\(notifications.count)")

    center.getPendingNotificationRequests { requests in
      let ids = requests.map(\.identifier).filter { $0.hasPrefix("solatify_prayer_") }
      center.removePendingNotificationRequests(withIdentifiers: ids)

      guard enabled else {
        result(nil)
        return
      }

      self.requestNotificationAuthorization { granted in
        guard granted else {
          result(FlutterError(code: "permission_denied", message: "Notification permission denied", details: nil))
          return
        }

        for item in notifications {
          guard
            let id = item["id"] as? Int,
            let title = item["title"] as? String,
            let body = item["body"] as? String,
            let timestampMs = item["timestampMs"] as? Double
          else { continue }

          let interval = Date(timeIntervalSince1970: timestampMs / 1000).timeIntervalSinceNow
          guard interval > 0 else { continue }

          let content = UNMutableNotificationContent()
          content.title = title
          content.body = body
          content.sound = self.notificationSound(playSound: playSound, soundName: soundName)
          if #available(iOS 15.0, *) {
            content.interruptionLevel = .active
          }

          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, interval), repeats: false)
          let request = UNNotificationRequest(
            identifier: "solatify_prayer_\(id)",
            content: content,
            trigger: trigger
          )
          center.add(request)
          NSLog("SolatifyNativeNotification: added prayer id=\(id) interval=\(interval) sound=\(soundName ?? "default")")
        }

        result(nil)
      }
    }
  }

  private func scheduleTestAdhanNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "bad_args", message: "Missing arguments", details: nil))
      return
    }

    let playSound = args["playSound"] as? Bool ?? true
    let soundName = args["soundName"] as? String
    let center = UNUserNotificationCenter.current()
    NSLog("SolatifyNativeNotification: scheduleTest playSound=\(playSound) sound=\(soundName ?? "default")")

    requestNotificationAuthorization { granted in
      guard granted else {
        result(FlutterError(code: "permission_denied", message: "Notification permission denied", details: nil))
        return
      }

      center.removePendingNotificationRequests(withIdentifiers: ["solatify_test_adhan"])
      let content = UNMutableNotificationContent()
      content.title = "Tes Adzan Solatify"
      content.body = "Jika ini muncul dan berbunyi, notifikasi adzan aktif."
      content.sound = self.notificationSound(playSound: playSound, soundName: soundName)
      if #available(iOS 15.0, *) {
        content.interruptionLevel = .active
      }

      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
      let request = UNNotificationRequest(
        identifier: "solatify_test_adhan",
        content: content,
        trigger: trigger
      )
      center.add(request) { error in
        if let error = error {
          NSLog("SolatifyNativeNotification: test schedule failed \(error.localizedDescription)")
          result(FlutterError(code: "schedule_failed", message: error.localizedDescription, details: nil))
        } else {
          NSLog("SolatifyNativeNotification: test scheduled")
          result(nil)
        }
      }
    }
  }

  private func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
      completion(granted)
    }
  }

  private func notificationSound(playSound: Bool, soundName: String?) -> UNNotificationSound? {
    guard playSound else { return nil }
    guard let soundName = soundName, !soundName.isEmpty else { return .default }
    return UNNotificationSound(named: UNNotificationSoundName(soundName))
  }

  private func copyAdhanSoundsToLibrary() {
    guard let soundsDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Sounds") else {
      return
    }

    try? FileManager.default.createDirectory(at: soundsDirectory, withIntermediateDirectories: true)
    for fileName in ["adhan_makkah.caf", "adhan_madinah.caf"] {
      guard let source = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".caf", with: ""), withExtension: "caf") else {
        continue
      }
      let destination = soundsDirectory.appendingPathComponent(fileName)
      do {
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.copyItem(at: source, to: destination)
        NSLog("SolatifyNativeNotification: copied \(fileName) to Library/Sounds")
      } catch {
        NSLog("SolatifyNativeNotification: failed copy \(fileName): \(error.localizedDescription)")
      }
    }
  }
}
