import UIKit
import AppBoxSDK

final class WebViewSampleViewController: SampleFeatureViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WebView · Swift"
        addIntroduction(
            "AppBox SDK가 관리하는 WebView를 현재 화면 위에 표시합니다. 초기화된 HTTPS Base URL이 필요합니다."
        )
        contentStack.addArrangedSubview(
            SampleUIFactory.button(
                title: "AppBox WebView 실행",
                target: self,
                action: #selector(startWebView)
            )
        )
        addResultSection()
    }

    @objc private func startWebView() {
        guard SampleConfiguration.validBaseURLString != nil else {
            showSettingsRequired(
                "Base URL을 AppBox Console 또는 구축 환경 담당자에게 확인해 설정하세요."
            )
            return
        }
        guard SampleStateStore.shared.isWebViewReady else {
            showSettingsRequired("WebView 모듈 초기화가 완료되지 않았습니다.")
            return
        }

        AppBox.start(from: self) { success, error in
            if success {
                SampleStateStore.shared.record(
                    category: "WebView",
                    message: "Swift 화면에서 WebView를 실행했습니다."
                )
                self.setResult("WebView 실행 요청이 성공했습니다.")
            } else {
                self.setResult(
                    error?.localizedDescription ?? "WebView 실행에 실패했습니다.",
                    isError: true
                )
            }
        }
    }
}
