import UIKit
import AppBoxSDK

final class InAppSampleViewController: SampleFeatureViewController {
    private var enteredDisplayScreen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Push 연계 In-App"
        addIntroduction(
            "이 예제는 In-App SDK 단독 사용이 아닙니다. AppBox Core와 Push가 모두 초기화된 상태에서 Native In-App을 동기화하고 표시 화면 lifecycle을 전달합니다."
        )
        contentStack.addArrangedSubview(
            SampleUIFactory.button(
                title: "In-App 메시지 동기화",
                target: self,
                action: #selector(syncInApp)
            )
        )
        addResultSection()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard SampleStateStore.shared.isPushReady,
              SampleStateStore.shared.isInAppReady,
              AppBox.isInAppAvailable() else {
            setResult("Push와 In-App 모듈 준비가 필요합니다.", isError: true)
            return
        }

        AppBox.setInAppActionListener { event in
            SampleStateStore.shared.record(
                category: "In-App",
                message: "In-App action을 수신했습니다: \(event.action)"
            )
        }
        AppBox.enterInAppDisplayScreen(delay: 0.3)
        enteredDisplayScreen = true
        setResult("In-App 표시 가능 화면으로 진입했습니다.")
    }

    override func viewDidDisappear(_ animated: Bool) {
        AppBox.setInAppActionListener(nil)
        if enteredDisplayScreen {
            AppBox.leaveInAppDisplayScreen()
            enteredDisplayScreen = false
            SampleStateStore.shared.record(
                category: "In-App",
                message: "In-App 표시 화면에서 이탈했습니다."
            )
        }
        super.viewDidDisappear(animated)
    }

    @objc private func syncInApp() {
        guard SampleConfiguration.canInitializeSDK else {
            showSettingsRequired("AppBox Project ID와 HTTPS Base URL을 먼저 설정하세요.")
            return
        }
        guard SampleStateStore.shared.isPushReady,
              SampleStateStore.shared.isInAppReady,
              AppBox.isInAppAvailable() else {
            showSettingsRequired("Push와 In-App 모듈 초기화가 모두 필요합니다.")
            return
        }

        AppBox.syncInApp { success, error in
            if success {
                SampleStateStore.shared.record(
                    category: "In-App",
                    message: "In-App 동기화가 완료되었습니다."
                )
                self.setResult("In-App 메시지 동기화가 완료되었습니다.")
            } else {
                self.setResult(
                    error?.localizedDescription ?? "In-App 동기화에 실패했습니다.",
                    isError: true
                )
            }
        }
    }
}
