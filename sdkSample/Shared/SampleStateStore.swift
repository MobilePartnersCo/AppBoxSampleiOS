import Foundation
import AppBoxSDK

extension Notification.Name {
    static let sampleStateDidChange = Notification.Name("SampleStateDidChange")
}

struct SampleLogEntry {
    let date: Date
    let category: String
    let message: String
}

final class SampleStateStore {
    static let shared = SampleStateStore()

    private(set) var initializationStarted = false
    private(set) var initializationCompleted = false
    private(set) var isCoreReady = false
    private(set) var isWebViewReady = false
    private(set) var isPushReady = false
    private(set) var isInAppReady = false
    private(set) var isAuthReady = false
    private(set) var isHealthReady = false
    private(set) var isAppsFlyerReady = false
    private(set) var moduleStatuses: [String: String] = [:]
    private(set) var pushAuthorization = "확인 전"
    private(set) var apnsRegistration = "요청 전"
    private(set) var lastPushCallback = "없음"
    private(set) var lastDeepLinkEvent = "없음"
    private(set) var logs: [SampleLogEntry] = []

    private let maximumLogCount = 100

    private init() {}

    func markInitializationStarted() {
        update {
            self.initializationStarted = true
            self.initializationCompleted = false
            self.appendLog(category: "SDK", message: "초기화를 시작했습니다.")
        }
    }

    func markConfigurationMissing() {
        update {
            self.initializationStarted = false
            self.moduleStatuses = [
                "Core": "설정 필요",
                "WebView": "설정 필요",
                "Push": "설정 필요",
                "In-App": "설정 필요",
                "SNS Login": "설정 필요",
                "Health": "초기화 전",
                "AppsFlyer": "설정 필요"
            ]
            self.appendLog(
                category: "설정",
                message: "Project ID와 HTTPS Base URL을 먼저 설정해야 합니다."
            )
        }
    }

    func updateInitialization(_ result: AppBoxInitResult) {
        update {
            self.initializationCompleted = true
            self.isCoreReady = result.core.status == .INITIALIZED
            self.isWebViewReady = result.webView.status == .INITIALIZED
            self.isPushReady = result.push.status == .INITIALIZED
            self.isInAppReady = result.inApp.status == .INITIALIZED
            self.isAuthReady = result.auth.status == .INITIALIZED
            self.isHealthReady = result.health.status == .INITIALIZED
            self.isAppsFlyerReady = result.appsFlyer.status == .INITIALIZED

            self.moduleStatuses = [
                "Core": self.statusText(result.core),
                "WebView": self.statusText(result.webView),
                "Push": self.statusText(result.push),
                "In-App": self.statusText(result.inApp),
                "SNS Login": self.statusText(result.auth),
                "Health": self.statusText(result.health),
                "AppsFlyer": self.statusText(result.appsFlyer)
            ]
            self.appendLog(
                category: "SDK",
                message: self.isCoreReady ? "Core 초기화가 완료되었습니다." : "Core 초기화에 실패했습니다."
            )
        }
    }

    func updatePushAuthorization(_ value: String) {
        update {
            self.pushAuthorization = value
            self.appendLog(category: "Push", message: "알림 권한 상태: \(value)")
        }
    }

    func updateAPNsRegistration(_ value: String) {
        update {
            self.apnsRegistration = value
            self.appendLog(category: "Push", message: "APNs 상태: \(value)")
        }
    }

    func recordPushCallback(_ callback: String) {
        update {
            self.lastPushCallback = callback
            self.appendLog(category: "Push", message: callback)
        }
    }

    func recordDeepLink(kind: String, handled: Bool) {
        update {
            let result = handled ? "SDK 처리" : "처리되지 않음"
            self.lastDeepLinkEvent = "\(kind) · \(result)"
            self.appendLog(category: "Deep Link", message: self.lastDeepLinkEvent)
        }
    }

    func recordAppsFlyer(_ status: AppBoxAppsFlyerDeepLinkStatus) {
        let statusText: String
        switch status {
        case .found:
            statusText = "딥링크 발견"
        case .notFound:
            statusText = "딥링크 없음"
        case .error:
            statusText = "딥링크 오류"
        @unknown default:
            statusText = "알 수 없는 상태"
        }

        update {
            self.lastDeepLinkEvent = "AppsFlyer · \(statusText)"
            self.appendLog(category: "AppsFlyer", message: statusText)
        }
    }

    func record(category: String, message: String) {
        update {
            self.appendLog(category: category, message: message)
        }
    }

    private func statusText(_ result: AppBoxModuleInitResult) -> String {
        switch result.status {
        case .INITIALIZED:
            return "초기화 완료"
        case .SKIPPED:
            return "생략됨 · \(result.message)"
        case .FAILED:
            return "실패 · \(result.message)"
        @unknown default:
            return "알 수 없음"
        }
    }

    private func appendLog(category: String, message: String) {
        logs.insert(
            SampleLogEntry(date: Date(), category: category, message: message),
            at: 0
        )
        if logs.count > maximumLogCount {
            logs.removeLast(logs.count - maximumLogCount)
        }
    }

    private func update(_ changes: @escaping () -> Void) {
        let work = {
            changes()
            NotificationCenter.default.post(name: .sampleStateDidChange, object: self)
        }

        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}
