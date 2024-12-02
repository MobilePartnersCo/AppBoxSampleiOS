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
        // AppBox SDK 초기화
        // -----------------------------------------------------------------------------------------
        let config = AppBoxWebConfig()
        config.allowsBackForwardNavigationGestures = true
        AppBox.shared.initSDK(baseUrl: "https://naver.com",webConfig: config, debugMode: false)
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
        if let introItem1 = AppBoxIntro(imageUrl: "이미지 url") {
            let items = [
                introItem1
            ]
            AppBox.shared.setIntro(items)
        }
        // -----------------------------------------------------------------------------------------
        
        // -----------------------------------------------------------------------------------------
        // AppBox 푸시 토큰 설정
        // -----------------------------------------------------------------------------------------
        AppBox.shared.setPushToken("푸시토큰")
        // -----------------------------------------------------------------------------------------
        
        // -----------------------------------------------------------------------------------------
        // AppBox pullDown Refresh 설정
        // -----------------------------------------------------------------------------------------
        AppBox.shared.setPullDownRefresh(used: true)
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

