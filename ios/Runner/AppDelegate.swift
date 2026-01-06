// import UIKit
// import Flutter
// import FirebaseCore
// import FirebaseMessaging
// import UserNotifications
//
// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//
//     if FirebaseApp.app() == nil {
//       FirebaseApp.configure()
//       Messaging.messaging().isAutoInitEnabled = true
//     }
//
//     GeneratedPluginRegistrant.register(with: self)
//
//     UNUserNotificationCenter.current().delegate = self
//
//     UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
//       if granted {
//         DispatchQueue.main.async {
//           UIApplication.shared.registerForRemoteNotifications()
//         }
//       }
//     }
//
//     Messaging.messaging().delegate = self
//
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
//
//   override func application(
//     _ application: UIApplication,
//     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
//   ) {
//     let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
//     let token = tokenParts.joined()
//     print("Device Token: \(token)")
//     Messaging.messaging().apnsToken = deviceToken
//   }
//
//   override func application(
//     _ application: UIApplication,
//     didFailToRegisterForRemoteNotificationsWithError error: Error
//   ) {
//     print("Failed to register: \(error)")
//   }
// }
//
// extension AppDelegate: MessagingDelegate {
//   func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//     print("[FCM] didReceiveRegistrationToken: \(fcmToken ?? "nil")")
//   }
// }
//
// extension AppDelegate {
//   override func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                        willPresent notification: UNNotification,
//                                        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//     if #available(iOS 14.0, *) {
//       completionHandler([.banner, .list, .sound, .badge])
//     } else {
//       completionHandler([.alert, .sound, .badge])
//     }
//   }
// }
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    Messaging.messaging().isAutoInitEnabled = true

    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self

    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .badge, .sound]
    ) { granted, _ in
      if granted {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }

    Messaging.messaging().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }

  override func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register: \(error)")
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

  override func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse,
      withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("[FCM] Token: \(fcmToken ?? "nil")")
  }
}
