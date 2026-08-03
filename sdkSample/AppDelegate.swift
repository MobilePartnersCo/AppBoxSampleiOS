import UIKit
import WebKit
import UserNotifications
import AppBoxSDK

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let stateStore = SampleStateStore.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        refreshPushAuthorizationStatus()

        guard SampleConfiguration.canInitializeSDK,
              let baseURL = SampleConfiguration.validBaseURLString else {
            stateStore.markConfigurationMissing()
            return true
        }

        let webConfig = AppBoxWebConfig()
        let wkWebViewConfiguration = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            wkWebViewConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            wkWebViewConfiguration.preferences.javaScriptEnabled = true
        }
        webConfig.wKWebViewConfiguration = wkWebViewConfiguration

        let pushConfig: AppBoxPushConfig
        if SampleConfiguration.hasGoogleLoginConfiguration {
            pushConfig = AppBoxPushConfig(
                firebaseClientID: SampleConfiguration.firebaseClientID
            )
        } else {
            pushConfig = AppBoxPushConfig()
        }

        let authConfig = AppBoxAuthConfig(
            googleEnabled: SampleConfiguration.hasGoogleLoginConfiguration,
            appleEnabled: SampleConfiguration.appleLoginEnabled,
            kakaoNativeAppKey: configuredValue(SampleConfiguration.kakaoNativeAppKey),
            naverAppName: configuredValue(SampleConfiguration.naverAppName),
            naverClientId: configuredValue(SampleConfiguration.naverClientID),
            naverClientSecret: configuredValue(SampleConfiguration.naverClientSecret),
            naverURLScheme: configuredValue(SampleConfiguration.naverURLScheme)
        )

        let appsFlyerConfig: AppBoxAppsFlyerConfig?
        if SampleConfiguration.hasAppsFlyerConfiguration {
            appsFlyerConfig = AppBoxAppsFlyerConfig(
                devKey: SampleConfiguration.appsFlyerDevKey,
                appleAppID: SampleConfiguration.appsFlyerAppleAppID,
                attTimeout: 0
            )
            configureAppsFlyerListeners()
        } else {
            appsFlyerConfig = nil
        }

        let config = AppBoxInitConfig(
            common: AppBoxCommonConfig(
                projectId: SampleConfiguration.projectID,
                debugMode: SampleConfiguration.debugMode
            ),
            webView: AppBoxWebViewConfig(
                baseURL: baseURL,
                webConfig: webConfig
            ),
            push: pushConfig,
            inApp: AppBoxInAppConfig(enabled: true),
            auth: authConfig,
            appsFlyer: appsFlyerConfig
        )

        stateStore.markInitializationStarted()
        AppBox.initialize(config) { result in
            if result.webView.status == .INITIALIZED {
                AppBox.setPullDownRefresh(true)
                AppBox.preloadWebView(completion: nil)
            }

            if result.appsFlyer.status == .INITIALIZED {
                AppBox.startAppsFlyer()
                self.stateStore.record(
                    category: "AppsFlyer",
                    message: "AppsFlyer를 시작했습니다."
                )
            }

            // 초기화 후속 동작까지 끝난 뒤 pending cold-start callback을 전달합니다.
            self.stateStore.updateInitialization(result)
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let accepted = AppBox.handleAPNSToken(deviceToken)
        stateStore.updateAPNsRegistration(
            accepted ? "SDK 전달 완료" : "SDK 전달 실패"
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        stateStore.updateAPNsRegistration("등록 실패")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        AppBox.handleRemoteNotification(userInfo: userInfo)
        stateStore.recordPushCallback("Background/Silent 알림을 전달했습니다.")
        completionHandler(.newData)
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }

    private func configuredValue(_ value: String) -> String? {
        SampleConfiguration.isConfigured(value) ? value : nil
    }

    private func configureAppsFlyerListeners() {
        AppBox.setAppsFlyerDeepLinkListener { result in
            SampleStateStore.shared.recordAppsFlyer(result.status)
        }
        AppBox.configureAppsFlyerJavaScriptBridge(
            AppBoxAppsFlyerJavaScriptBridgeConfig(
                deliverNotFoundAndError: false,
                pendingLimit: 10
            )
        )
    }

    private func refreshPushAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .notDetermined:
                status = "요청 전"
            case .denied:
                status = "거부됨"
            case .authorized:
                status = "허용됨"
            case .provisional:
                status = "임시 허용"
            case .ephemeral:
                status = "일시 허용"
            @unknown default:
                status = "알 수 없음"
            }
            self.stateStore.updatePushAuthorization(status)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        AppBox.movePush(response)
        stateStore.recordPushCallback("알림 클릭 정보를 전달했습니다.")
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        let accepted = AppBox.handleForegroundNotification(notification.request)
        stateStore.recordPushCallback(
            accepted
                ? "Foreground 알림을 전달했습니다."
                : "Foreground 알림 전달이 거절되었습니다."
        )
        completionHandler([.badge, .alert, .sound])
    }
}
