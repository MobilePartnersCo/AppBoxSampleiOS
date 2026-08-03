import UIKit
import UserNotifications
import AppBoxSDK

final class PushSampleViewController: SampleFeatureViewController {
    private let permissionLabel = SampleUIFactory.label()
    private let registrationLabel = SampleUIFactory.label()
    private let callbackLabel = SampleUIFactory.label()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Push"
        addIntroduction(
            "Push SDK는 이 종합 데모앱의 필수 기반입니다. OS 권한 요청은 앱 시작 시 자동 실행하지 않고 아래 버튼을 누를 때만 시작합니다."
        )
        addSectionTitle("현재 상태")
        contentStack.addArrangedSubview(permissionLabel)
        contentStack.addArrangedSubview(registrationLabel)
        contentStack.addArrangedSubview(callbackLabel)
        contentStack.addArrangedSubview(
            SampleUIFactory.button(
                title: "Push 권한 요청 및 APNs 등록",
                target: self,
                action: #selector(requestPermission)
            )
        )
        addResultSection()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(render),
            name: .sampleStateDidChange,
            object: nil
        )
        refreshAuthorizationStatus()
        render()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func render() {
        let store = SampleStateStore.shared
        permissionLabel.text = "알림 권한: \(store.pushAuthorization)"
        registrationLabel.text = "APNs 등록: \(store.apnsRegistration)"
        callbackLabel.text = "최근 callback: \(store.lastPushCallback)"
        permissionLabel.accessibilityLabel = permissionLabel.text
        registrationLabel.accessibilityLabel = registrationLabel.text
        callbackLabel.accessibilityLabel = callbackLabel.text
    }

    @objc private func requestPermission() {
        guard SampleConfiguration.canInitializeSDK else {
            showSettingsRequired("AppBox Project ID와 HTTPS Base URL을 먼저 설정하세요.")
            return
        }
        guard SampleStateStore.shared.isPushReady else {
            showSettingsRequired("Push 모듈 초기화가 완료되지 않았습니다.")
            return
        }

        AppBox.requestPushPermission { granted, error in
            if let error {
                SampleStateStore.shared.updatePushAuthorization("요청 실패")
                self.setResult(error.localizedDescription, isError: true)
                return
            }
            guard granted else {
                SampleStateStore.shared.updatePushAuthorization("허용되지 않음")
                self.setResult("사용자가 알림 권한을 허용하지 않았습니다.", isError: true)
                return
            }

            SampleStateStore.shared.updatePushAuthorization("허용됨")
            let requested = AppBox.registerForRemoteNotifications()
            SampleStateStore.shared.updateAPNsRegistration(
                requested ? "등록 요청 접수" : "등록 요청 실패"
            )
            self.setResult(
                requested
                    ? "APNs 등록 요청을 시작했습니다. 완료 여부는 AppDelegate callback에서 확인합니다."
                    : "SDK가 APNs 등록 요청을 시작하지 못했습니다.",
                isError: !requested
            )
        }
    }

    private func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .notDetermined: status = "요청 전"
            case .denied: status = "거부됨"
            case .authorized: status = "허용됨"
            case .provisional: status = "임시 허용"
            case .ephemeral: status = "일시 허용"
            @unknown default: status = "알 수 없음"
            }
            SampleStateStore.shared.updatePushAuthorization(status)
        }
    }
}
