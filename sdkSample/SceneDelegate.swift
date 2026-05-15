//
//  SceneDelegate.swift
//  sdkSample
//
//  Created by mobilePartners on 11/26/24.
//

import UIKit
import AppBoxSDK

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let _ = (scene as? UIWindowScene) else { return }

        // [공통] 앱이 종료된 상태에서 열린 Universal Link/URL scheme도 SDK에 전달합니다.
        for userActivity in connectionOptions.userActivities {
            _ = AppBox.shared.handleUserActivity(userActivity)
        }

        for urlContext in connectionOptions.urlContexts {
            _ = AppBox.shared.handleURL(
                urlContext.url,
                options: appOpenOptions(from: urlContext.options)
            )
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }

        // [공통] Scene 기반 앱에서는 URL scheme callback이 AppDelegate 대신 이 메서드로 들어올 수 있습니다.
        _ = AppBox.shared.handleURL(
            urlContext.url,
            options: appOpenOptions(from: urlContext.options)
        )
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // [공통] 필요한 UserActivity를 AppBox 처리 경로로 전달합니다.
        _ = AppBox.shared.handleUserActivity(userActivity)
    }

    private func appOpenOptions(from options: UIScene.OpenURLOptions) -> [UIApplication.OpenURLOptionsKey: Any] {
        var result: [UIApplication.OpenURLOptionsKey: Any] = [:]

        if let sourceApplication = options.sourceApplication {
            result[.sourceApplication] = sourceApplication
        }

        result[.annotation] = options.annotation
        result[.openInPlace] = options.openInPlace
        return result
    }
}
