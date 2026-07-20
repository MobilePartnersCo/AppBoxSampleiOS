//
//  AppDelegate.swift
//  sdkSample
//
//  Created by mobilePartners on 11/26/24.
//

import UIKit
import WebKit
import UserNotifications
import AppBoxSDK

// 주석 prefix 기준:
// [공통] 앱 lifecycle, push callback, URL callback처럼 여러 통합 방식에서 확인할 처리입니다.
// [AppBox 기본 WebView] AppBoxSDK가 WKWebView를 생성/관리하는 기본 샘플 흐름입니다.
// [선택: AppsFlyer], [선택: SNS 로그인] 해당 기능을 쓰는 앱만 적용합니다.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // -----------------------------------------------------------------------------------------
        // [공통] 푸시를 받기 위한 설정
        // 앱이 foreground에 있을 때도 푸시 표시/클릭 처리를 받기 위해 delegate를 지정합니다.
        // -----------------------------------------------------------------------------------------
        UNUserNotificationCenter.current().delegate = self

        // 이 실행 target은 Push, SNS Login, Health를 모두 연결한 전체 기능 확인용 샘플입니다.
        // 아래 AppBoxInitConfig 구성이 SDK 사용자가 실제로 작성하는 초기화 코드입니다.
        // Base + Push 기본 구성과 목적별 Product 선택은 README를 함께 확인합니다.

        // [선택: WebView 세부 설정] 별도 WKWebViewConfiguration이 필요할 때 구성합니다.
        let appBoxWebConfig = AppBoxWebConfig()
        let wkWebViewConfig = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            wkWebViewConfig.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            wkWebViewConfig.preferences.javaScriptEnabled = true
        }
        appBoxWebConfig.wKWebViewConfiguration = wkWebViewConfig

        // [필수] 모든 AppBoxSDK 서비스 앱이 사용하는 project와 debug 설정입니다.
        let common = AppBoxCommonConfig(
            projectId: "AAA-000000",
            debugMode: true
        )

        // [필수: AppBox 관리 WebView] 처음 표시할 URL과 WebView 설정입니다.
        let webView = AppBoxWebViewInitConfig(
            baseURL: "https://www.example.com",
            webConfig: appBoxWebConfig
        )

        // [필수: Push / 선택: Google 로그인]
        // AppBoxSDK 서비스 앱은 Push config를 공통으로 포함합니다.
        // 이 샘플은 Google 로그인을 활성화하므로 Firebase OAuth Client ID도 전달합니다.
        // Base + Push만 사용하는 앱은 AppBoxPushInitConfig()를 사용합니다.
        let push = AppBoxPushInitConfig(
            firebaseClientID: "YOUR_FIREBASE_CLIENTID"
        )

        // [선택: SNS 로그인] SNS 로그인을 사용하지 않으면 auth를 config에서 생략합니다.
        // 사용하는 provider만 활성화하고 각 console에서 발급한 실제 값으로 교체합니다.
        let auth = AppBoxAuthInitConfig(
            googleEnabled: true,
            appleEnabled: true,
            kakaoNativeAppKey: "YOUR_KAKAO_APPKEY",
            naverAppName: "YOUR_NID_APPNAME",
            naverClientId: "YOUR_NID_CLIENTID",
            naverClientSecret: "YOUR_NID_CLIENTSECRET",
            naverURLScheme: "YOUR_NID_URLSCHEME"
        )

        // [선택: AppsFlyer] 사용하지 않으면 nil로 둡니다.
        // 사용할 때는 README의 AppBoxAppsFlyerConfig 예제로 교체합니다.
        let appsFlyer: AppBoxAppsFlyerConfig? = nil

        // SDK 초기화에 전달하는 공식 공개 설정 객체입니다.
        let config = AppBoxInitConfig(
            common: common,
            webView: webView,
            push: push,
            auth: auth,
            appsFlyer: appsFlyer
        )

        AppBox.initialize(config) { result in
            // INITIALIZED: 사용 가능
            // SKIPPED: 설정하지 않았거나 현재 앱에 해당 Product가 연결되지 않음
            // FAILED: 초기화 실패. message에서 원인을 확인합니다.
            print("[AppBoxSample] Core: \(result.core.status.rawValue) - \(result.core.message)")
            print("[AppBoxSample] WebView: \(result.webView.status.rawValue) - \(result.webView.message)")
            print("[AppBoxSample] Push: \(result.push.status.rawValue) - \(result.push.message)")
            print("[AppBoxSample] In-App: \(result.inApp.status.rawValue) - \(result.inApp.message)")
            print("[AppBoxSample] SNS Login: \(result.auth.status.rawValue) - \(result.auth.message)")
            print("[AppBoxSample] Health: \(result.health.status.rawValue) - \(result.health.message)")
            print("[AppBoxSample] AppsFlyer: \(result.appsFlyer.status.rawValue) - \(result.appsFlyer.message)")

            if result.webView.status == .INITIALIZED {
                AppBox.preloadWebView(completion: nil)
            }

            if result.appsFlyer.status == .INITIALIZED {
                AppBox.configureAppsFlyerJavaScriptBridge(
                    AppBoxAppsFlyerJavaScriptBridgeConfig()
                )
                AppBox.startAppsFlyer()
            }

            // AppBox.initialize는 Push 권한 요청이나 APNs 등록을 자동으로 시작하지 않습니다.
            guard result.push.status == .INITIALIZED else { return }
            AppBox.requestPushAuthorization { granted, error in
                if let error {
                    print("Push 권한 요청 실패: \(error.localizedDescription)")
                    return
                }
                guard granted else {
                    print("사용자가 Push 권한을 허용하지 않았습니다.")
                    return
                }
                guard AppBox.registerForRemoteNotifications() else {
                    print("APNs 등록 요청을 시작하지 못했습니다.")
                    return
                }
            }
        }

        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox 인트로 설정 (선택)
        // -----------------------------------------------------------------------------------------
        if let introItem1 = AppBoxIntroItems(
            imageUrl: "https://example.com/image.jpg"
        ) {
            let items = [introItem1]
            let intro = AppBoxIntro(
                indicatorDefColor: "#a7abab",
                indicatorSelColor: "#000000",
                fontColor: "#000000",
                item: items
            )
            AppBox.setIntro(intro)
        } else {
            print("Failed to initialize AppBoxIntro with empty URL.")
        }

        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox 당겨서 새로고침 설정
        // -----------------------------------------------------------------------------------------
        AppBox.setPullDownRefresh(true)

        return true
    }

    // MARK: - [공통] Push: APNs Token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // [공통] APNs deviceToken을 SDK에 전달해야 AppBox push token 매핑이 완료됩니다.
        _ = AppBox.handleAPNSToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APNs registration failed: \(error.localizedDescription)")
    }

    // MARK: - [공통] URL Callback (SNS 로그인/AppsFlyer/외부앱 복귀 처리)
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // AppBox가 SNS 로그인, Push, AppsFlyer URI Scheme을 알맞은 기능으로 전달합니다.
        if AppBox.handleURL(url, options: options) { return true }
        return false
    }

    // MARK: - [공통] Universal Link / UserActivity Callback
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // [공통] 필요한 UserActivity를 AppBox 처리 경로로 전달합니다.
        _ = AppBox.handleUserActivity(userActivity)
        return false
    }

    // MARK: UISceneSession Lifecycle
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
}

// MARK: - [공통] UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    // [공통] 알림이 클릭이 되었을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // [공통] 클릭 정보를 SDK에 전달하면 INAPP/URL 이동 및 오픈 통계 처리가 이어집니다.
        AppBox.movePush(response)
        completionHandler()
    }

    // [공통] foreground일 때, 알림이 발생
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        _ = AppBox.handleForegroundNotification(notification.request)
        completionHandler([.badge, .alert, .sound])
    }
}

// MARK: - [AppBox 기본 WebView] InApp Message (선택)
// [AppBox 기본 WebView] 인앱 메시지 사용 시: UIApplicationDelegate 메서드로 구현하는 게 맞습니다.
extension AppDelegate {
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (
            UIBackgroundFetchResult
        ) -> Void
    ) {
        // [AppBox 기본 WebView] silent/in-app push payload를 SDK 큐로 전달합니다.
        AppBox.handleRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
}
