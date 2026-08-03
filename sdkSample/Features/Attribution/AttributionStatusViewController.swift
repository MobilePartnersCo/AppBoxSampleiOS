import UIKit

final class AttributionStatusViewController: SampleFeatureViewController {
    private let configurationLabel = SampleUIFactory.label()
    private let eventLabel = SampleUIFactory.label()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AppsFlyer 및 딥링크"
        addIntroduction(
            "AppsFlyer listener와 JavaScript bridge는 유효한 설정이 있을 때 앱 lifecycle에서 먼저 구성되고 한 번만 시작됩니다. 전체 URL과 raw parameter는 저장하지 않습니다."
        )
        addSectionTitle("현재 상태")
        contentStack.addArrangedSubview(configurationLabel)
        contentStack.addArrangedSubview(eventLabel)

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
        let configured = SampleConfiguration.hasAppsFlyerConfiguration
        configurationLabel.text = configured
            ? "AppsFlyer 설정: 설정됨"
            : "AppsFlyer 설정: 설정 필요\n출처: AppsFlyer Dashboard > App Settings"
        eventLabel.text = "최근 정제 이벤트: \(SampleStateStore.shared.lastDeepLinkEvent)"
        configurationLabel.accessibilityLabel = configurationLabel.text
        eventLabel.accessibilityLabel = eventLabel.text
    }
}
