import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    registerNotificationChannelIfPossible()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.registerNotificationChannelIfPossible()
    }
  }

  private func registerNotificationChannelIfPossible() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      NSLog("SolatifyNativeNotification: SceneDelegate FlutterViewController not ready")
      return
    }
    (UIApplication.shared.delegate as? AppDelegate)?.setupNotificationChannel(controller: controller)
  }

}
