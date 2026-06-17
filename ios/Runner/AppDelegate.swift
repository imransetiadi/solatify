import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerIosSettingsChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
      default:
        result(FlutterMethodNotImplemented)
      }
    }
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
