import UIKit

final class StatusViewController: SampleFeatureViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SDK 및 설정 상태"
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(render),
            name: .sampleStateDidChange,
            object: nil
        )
        render()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func render() {
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        addIntroduction(
            "실제 키는 저장소에 포함하지 않습니다. 미설정 항목은 출처를 확인해 SampleConfiguration.swift에서 교체하세요."
        )
        addSectionTitle("설정값")
        for setting in SampleConfiguration.settings {
            contentStack.addArrangedSubview(
                SampleUIFactory.card(
                    title: setting.name,
                    value: setting.isConfigured ? setting.displayValue : "설정 필요",
                    detail: "출처: \(setting.source)"
                )
            )
        }

        addSectionTitle("SDK 모듈")
        let store = SampleStateStore.shared
        let names = ["Core", "WebView", "Push", "In-App", "SNS Login", "Health", "AppsFlyer"]
        for name in names {
            contentStack.addArrangedSubview(
                SampleUIFactory.card(
                    title: name,
                    value: store.moduleStatuses[name] ?? "초기화 대기"
                )
            )
        }
    }
}
