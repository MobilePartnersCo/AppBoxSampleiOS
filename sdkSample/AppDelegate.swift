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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // -----------------------------------------------------------------------------------------
        // 푸시를 받기 위한 설정
        // -----------------------------------------------------------------------------------------
        UNUserNotificationCenter.current().delegate = self

        // -----------------------------------------------------------------------------------------
        // AppBox WebConfig 설정
        // -----------------------------------------------------------------------------------------
        let appBoxWebConfig = AppBoxWebConfig()
        let wkWebViewConfig = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            wkWebViewConfig.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            wkWebViewConfig.preferences.javaScriptEnabled = true
        }
        appBoxWebConfig.wKWebViewConfiguration = wkWebViewConfig

        // -----------------------------------------------------------------------------------------
        // AppBox 초기화
        // -----------------------------------------------------------------------------------------
        AppBox.shared.initSDK(
            baseUrl: "https://www.example.com",
            projectId: "프로젝트 아이디",
            webConfig: appBoxWebConfig,
            debugMode: true
        )
        
        // -----------------------------------------------------------------------------------------
        // 웹뷰 사전 로딩
        // -----------------------------------------------------------------------------------------
        AppBox.shared.preloadWebView()

        // -----------------------------------------------------------------------------------------
        // AppBox 인트로 설정 (선택)
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
        // AppBox 당겨서 새로고침 설정
        // -----------------------------------------------------------------------------------------
        AppBox.shared.setPullDownRefresh(used: true)

        // -----------------------------------------------------------------------------------------
        // SNS 로그인 초기화 (사용하는 것만 선택)
        // -----------------------------------------------------------------------------------------
        AppBoxSnsLogin.shared
            .initializeKakao(appKey: "YOUR_KAKAO_APPKEY") // 카카오

        AppBoxSnsLogin.shared.initializeNaver(
            appName: "YOUR_NID_APPNAME",
            clientId: "YOUR_NID_CLIENTID",
            clientSecret: "YOUR_NID_CLIENTSECRET",
            urlScheme: "YOUR_NID_URLSCHEME"
        ) // 네이버

        // 구글 로그인: Firebase Client ID 설정 필요
        AppBoxPush.shared.initializeFirebaseClientID(
            clientID: "YOUR_FIREBASE_CLIENTID"
        )

        return true
    }

    // MARK: - Push: APNs Token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        AppBoxPush.shared.appBoxPushApnsToken(apnsToken: deviceToken)
    }

    // MARK: - URL Callback (SNS 로그인/외부앱 복귀 처리)
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if AppBox.shared.handleURL(url) { return true }
        if AppBoxSnsLogin.shared.handleURL(url) { return true }
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

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    // 알림이 클릭이 되었을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        AppBox.shared.movePush(response: response)
        completionHandler()
    }

    // foreground일 때, 알림이 발생
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        completionHandler([.badge, .alert, .sound])
    }
}

// MARK: - InApp Message (선택)
// 인앱 메시지 사용 시: UIApplicationDelegate 메서드로 구현하는 게 맞습니다.
extension AppDelegate {
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (
            UIBackgroundFetchResult
        ) -> Void
    ) {
        AppBox.shared.handledidReceiveRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
}
