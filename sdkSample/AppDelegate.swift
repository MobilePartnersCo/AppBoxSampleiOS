//
//  AppDelegate.swift
//  sdkSample
//
//  Created by mobilePartners on 11/26/24.
//

import UIKit
import AppBoxSDK
import AppBoxPushSDK
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
            projectId: "프로젝트 아이디",
            webConfig: appBoxWebConfig,
            debugMode: true
        )
        // -----------------------------------------------------------------------------------------
        
        
        // -----------------------------------------------------------------------------------------
        // AppBox 인트로 설정
        // -----------------------------------------------------------------------------------------
        if let introItem1 = AppBoxIntroItems(imageUrl: "https://example.com/image.jpg") {
           let items = [introItem1]
           let intro = AppBoxIntro(indicatorDefColor: "#a7abab", indicatorSelColor: "#000000", fontColor: "#000000", item: items)
        } else {
           print("Failed to initialize AppBoxIntro with empty URL.")
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // -----------------------------------------------------------------------------------------
        // AppBoxPushSDK 초기화
        // -----------------------------------------------------------------------------------------
        AppBoxPush.shared.appBoxPushApnsToken(apnsToken: deviceToken)
        // -----------------------------------------------------------------------------------------
    }
}

