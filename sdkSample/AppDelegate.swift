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
import AppBoxPushSDK
import AppBoxSnsLoginSDK

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

        // -----------------------------------------------------------------------------------------
        // [선택: SNS 로그인] Firebase Client ID 설정
        // Google 로그인 등 Firebase Client ID가 필요한 기능은 AppBox 초기화 전에 호출합니다.
        // -----------------------------------------------------------------------------------------
        AppBoxPush.shared.initializeFirebaseClientID(
            clientID: "YOUR_FIREBASE_CLIENTID"
        )

        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox WebConfig 설정
        // -----------------------------------------------------------------------------------------
        let appBoxWebConfig = AppBoxWebConfig()
        let wkWebViewConfig = WKWebViewConfiguration()
        // [AppBox 기본 WebView] 웹에서 사용하는 JavaScript bridge가 동작할 수 있도록 JS 실행을 허용합니다.
        if #available(iOS 14.0, *) {
            wkWebViewConfig.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            wkWebViewConfig.preferences.javaScriptEnabled = true
        }
        appBoxWebConfig.wKWebViewConfiguration = wkWebViewConfig

        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox 초기화
        // baseUrl과 projectId는 AppBox 콘솔에서 발급받은 서비스 값으로 교체합니다.
        // -----------------------------------------------------------------------------------------
        AppBox.shared.initSDK(
            baseUrl: "https://www.example.com",
            projectId: "프로젝트 아이디",
            webConfig: appBoxWebConfig,
            debugMode: true
        )

        // [선택: AppsFlyer] AppsFlyer URI Scheme 딥링크를 사용하는 앱만 값을 입력하면 활성화됩니다.
        configureAppsFlyerDeepLinking()
        
        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] 웹뷰 사전 로딩
        // -----------------------------------------------------------------------------------------
        AppBox.shared.preloadWebView()

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
            AppBox.shared.setIntro(intro)
        } else {
            print("Failed to initialize AppBoxIntro with empty URL.")
        }

        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox 당겨서 새로고침 설정
        // -----------------------------------------------------------------------------------------
        AppBox.shared.setPullDownRefresh(used: true)

        // -----------------------------------------------------------------------------------------
        // [선택: SNS 로그인] SNS 로그인 초기화 (사용하는 것만 선택)
        // -----------------------------------------------------------------------------------------
        AppBoxSnsLogin.shared
            .initializeKakao(appKey: "YOUR_KAKAO_APPKEY") // 카카오

        AppBoxSnsLogin.shared.initializeNaver(
            appName: "YOUR_NID_APPNAME",
            clientId: "YOUR_NID_CLIENTID",
            clientSecret: "YOUR_NID_CLIENTSECRET",
            urlScheme: "YOUR_NID_URLSCHEME"
        ) // 네이버

        // [선택: SNS 로그인] 구글 로그인은 위 Firebase Client ID 설정을 사용합니다.

        return true
    }

    // MARK: - [공통] Push: APNs Token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // [공통] APNs deviceToken을 SDK에 전달해야 AppBox push token 매핑이 완료됩니다.
        AppBoxPush.shared.appBoxPushApnsToken(apnsToken: deviceToken)
    }

    // MARK: - [공통] URL Callback (SNS 로그인/AppsFlyer/외부앱 복귀 처리)
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // [공통] AppBox.shared.handleURL이 SNS 로그인, Push, AppsFlyer URI Scheme을 내부 라우팅합니다.
        if AppBox.shared.handleURL(url, options: options) { return true }
        return false
    }

    // MARK: - [공통] Universal Link / UserActivity Callback
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // [공통] 필요한 UserActivity를 AppBox 처리 경로로 전달합니다.
        _ = AppBox.shared.handleUserActivity(userActivity)
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

private extension AppDelegate {
    func configureAppsFlyerDeepLinking() {
        let appsFlyerDevKey = ""
        let appsFlyerAppleAppID = ""

        guard !appsFlyerDevKey.isEmpty, !appsFlyerAppleAppID.isEmpty else {
            return
        }

        // [선택: AppsFlyer] Xcode URL Types에 URI Scheme을 등록하고,
        // AppsFlyer Console deep link URL은 {scheme}://open 형태로 설정합니다.
        AppBox.shared.configureAppsFlyer(
            devKey: appsFlyerDevKey,
            appleAppID: appsFlyerAppleAppID
        )
        AppBox.shared.configureAppsFlyerJavaScriptBridge()
        AppBox.shared.startAppsFlyer()
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
        AppBox.shared.movePush(response: response)
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
        // [공통] foreground 수신 시에도 배지/알림/소리를 표시하도록 지정합니다.
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
        AppBox.shared.handledidReceiveRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
}
