//
//  AppDelegate.swift
//  sdkSample
//
//  Created by mobilePartners on 11/26/24.
//

import UIKit
import AppBoxSDK
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

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
        
        // -----------------------------------------------------------------------------------------
        // AppBox 초기화
        // -----------------------------------------------------------------------------------------
        AppBox.shared.initSDK(
            baseUrl: "https://www.example.com",
            webConfig: appBoxWebConfig,
            debugMode: true
        )
        // -----------------------------------------------------------------------------------------
        
        // -----------------------------------------------------------------------------------------
        // AppBox 푸시 토큰 설정
        // -----------------------------------------------------------------------------------------
        AppBox.shared.setPushToken("푸시 토큰 값")
        // -----------------------------------------------------------------------------------------
        
        // -----------------------------------------------------------------------------------------
        // AppBox 로컬 푸시 설정
        // -----------------------------------------------------------------------------------------
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // -----------------------------------------------------------------------------------------
        
        // -----------------------------------------------------------------------------------------
        // AppBox 인트로 설정
        // -----------------------------------------------------------------------------------------
        if let appBoxIntroItem1 = AppBoxIntro(imageUrl: "https://www.example.com/example1.png"),
           let appBoxIntroItem2 = AppBoxIntro(imageUrl: "https://www.example.com/example2.png") {
            let items = [
                appBoxIntroItem1,
                appBoxIntroItem2
            ]
            AppBox.shared.setIntro(items)
        }
        // -----------------------------------------------------------------------------------------
        
        
        // -----------------------------------------------------------------------------------------
        // AppBox 당겨서 새로고침 설정
        // -----------------------------------------------------------------------------------------
        AppBox.shared.setPullDownRefresh(
            used: true
        )
        // -----------------------------------------------------------------------------------------
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

// -----------------------------------------------------------------------------------------
// AppBox 로컬 푸시 설정
// -----------------------------------------------------------------------------------------
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

