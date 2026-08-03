import UIKit
import AppBoxSDK

@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private enum PendingRoute {
        case url(
            URL,
            [UIApplication.OpenURLOptionsKey: Any],
            kind: String
        )
        case userActivity(NSUserActivity, kind: String)
    }

    var window: UIWindow?
    private var pendingRoutes: [PendingRoute] = []

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard scene is UIWindowScene else { return }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(drainPendingRoutesIfReady),
            name: .sampleStateDidChange,
            object: nil
        )

        for userActivity in connectionOptions.userActivities {
            route(userActivity: userActivity, kind: "Cold Start Universal Link")
        }

        for urlContext in connectionOptions.urlContexts {
            route(urlContext: urlContext, kind: "Cold Start URL Scheme")
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        for urlContext in URLContexts {
            route(urlContext: urlContext, kind: "URL Scheme")
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        route(userActivity: userActivity, kind: "Universal Link")
    }

    private func route(urlContext: UIOpenURLContext, kind: String) {
        route(
            url: urlContext.url,
            options: appOpenOptions(from: urlContext.options),
            kind: kind
        )
    }

    private func route(
        url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any],
        kind: String
    ) {
        guard SampleConfiguration.canInitializeSDK else {
            SampleStateStore.shared.recordDeepLink(kind: kind, handled: false)
            return
        }

        guard SampleStateStore.shared.initializationCompleted else {
            pendingRoutes.append(.url(url, options, kind: kind))
            return
        }

        deliver(url: url, options: options, kind: kind)
    }

    private func route(userActivity: NSUserActivity, kind: String) {
        guard SampleConfiguration.canInitializeSDK else {
            SampleStateStore.shared.recordDeepLink(kind: kind, handled: false)
            return
        }

        guard SampleStateStore.shared.initializationCompleted else {
            pendingRoutes.append(.userActivity(userActivity, kind: kind))
            return
        }

        deliver(userActivity: userActivity, kind: kind)
    }

    @objc private func drainPendingRoutesIfReady() {
        guard SampleConfiguration.canInitializeSDK,
              SampleStateStore.shared.initializationCompleted,
              !pendingRoutes.isEmpty else {
            return
        }

        let routes = pendingRoutes
        pendingRoutes.removeAll()

        for route in routes {
            switch route {
            case let .url(url, options, kind):
                deliver(url: url, options: options, kind: kind)
            case let .userActivity(userActivity, kind):
                deliver(userActivity: userActivity, kind: kind)
            }
        }
    }

    private func deliver(
        url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any],
        kind: String
    ) {
        let handled = AppBox.handleURL(url, options: options)
        SampleStateStore.shared.recordDeepLink(kind: kind, handled: handled)
    }

    private func deliver(userActivity: NSUserActivity, kind: String) {
        let handled = AppBox.handleUserActivity(userActivity)
        SampleStateStore.shared.recordDeepLink(kind: kind, handled: handled)
    }

    private func appOpenOptions(
        from options: UIScene.OpenURLOptions
    ) -> [UIApplication.OpenURLOptionsKey: Any] {
        var result: [UIApplication.OpenURLOptionsKey: Any] = [:]

        if let sourceApplication = options.sourceApplication {
            result[.sourceApplication] = sourceApplication
        }
        result[.annotation] = options.annotation
        result[.openInPlace] = options.openInPlace
        return result
    }
}
