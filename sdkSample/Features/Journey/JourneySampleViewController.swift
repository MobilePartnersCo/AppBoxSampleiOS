import UIKit
import AppBoxSDK

final class JourneySampleViewController: SampleFeatureViewController {
    private let eventKeyField = SampleUIFactory.textField(
        placeholder: SampleConfiguration.journeyEventKeyExample
    )
    private let conversionCodeField = SampleUIFactory.textField(
        placeholder: SampleConfiguration.conversionCodeExample
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "사용자 여정 및 전환"
        addIntroduction(
            "AppBox Console에 정의된 event key와 conversion code를 사용하세요. 동일 행동을 중복 전송하지 말고 device user ID를 인증 ID로 사용하지 마세요."
        )
        contentStack.addArrangedSubview(eventKeyField)
        contentStack.addArrangedSubview(
            SampleUIFactory.button(
                title: "Journey Event 기록",
                target: self,
                action: #selector(trackJourney)
            )
        )
        contentStack.addArrangedSubview(conversionCodeField)
        contentStack.addArrangedSubview(
            SampleUIFactory.button(
                title: "Conversion 기록",
                target: self,
                action: #selector(trackConversion)
            )
        )
        contentStack.addArrangedSubview(
            SampleUIFactory.button(
                title: "Device User ID 발급 여부 확인",
                target: self,
                action: #selector(checkDeviceUserID)
            )
        )
        addResultSection()
    }

    @objc private func trackJourney() {
        guard ensurePushReady() else { return }
        let eventKey = trimmed(eventKeyField.text)
        guard !eventKey.isEmpty, SampleConfiguration.isConfigured(eventKey) else {
            setResult("AppBox Console에 등록한 event key를 입력하세요.", isError: true)
            return
        }
        AppBox.trackJourneyEvent(eventKey)
        setResult("Journey Event 기록을 요청했습니다.")
        SampleStateStore.shared.record(
            category: "Journey",
            message: "Journey Event 기록을 요청했습니다."
        )
    }

    @objc private func trackConversion() {
        guard ensurePushReady() else { return }
        let code = trimmed(conversionCodeField.text)
        guard !code.isEmpty, SampleConfiguration.isConfigured(code) else {
            setResult("AppBox Console에 등록한 conversion code를 입력하세요.", isError: true)
            return
        }
        AppBox.trackConversion(code) { success, error in
            if success {
                self.setResult("Conversion 기록이 완료되었습니다.")
                SampleStateStore.shared.record(
                    category: "Conversion",
                    message: "Conversion 기록이 완료되었습니다."
                )
            } else {
                self.setResult(
                    error?.localizedDescription ?? "Conversion 기록에 실패했습니다.",
                    isError: true
                )
            }
        }
    }

    @objc private func checkDeviceUserID() {
        guard SampleStateStore.shared.isCoreReady else {
            showSettingsRequired("Core SDK 초기화가 완료되지 않았습니다.")
            return
        }
        let deviceUserID = AppBox.getDeviceUserId()
        let message = deviceUserID.isEmpty
            ? "Device User ID가 아직 발급되지 않았습니다."
            : "Device User ID가 발급되었습니다. 원문은 표시하지 않습니다."
        setResult(message)
    }

    private func ensurePushReady() -> Bool {
        guard SampleConfiguration.canInitializeSDK,
              SampleStateStore.shared.isCoreReady,
              SampleStateStore.shared.isPushReady else {
            showSettingsRequired("Core와 Push 모듈 초기화가 필요합니다.")
            return false
        }
        return true
    }

    private func trimmed(_ value: String?) -> String {
        value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
