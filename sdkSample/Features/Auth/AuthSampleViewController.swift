import UIKit
import WebKit
import AppBoxSDK

final class AuthSampleViewController: SampleFeatureViewController {
    private let descriptorLabel = SampleUIFactory.label()
    private let naverWebView = WKWebView(frame: .zero)
    private var lastSignedInProvider: AppBoxAuthProvider?

    private let providers: [AppBoxAuthProvider] = [.google, .apple, .kakao, .naver]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SNS 로그인"
        addIntroduction(
            "Provider별 외부 Console 값, URL Scheme, Apple Capability를 먼저 설정하세요. 사용자 ID와 provider token은 화면이나 로그에 표시하지 않습니다."
        )
        addSectionTitle("Provider 상태")
        contentStack.addArrangedSubview(descriptorLabel)

        for provider in providers {
            let button = SampleUIFactory.button(
                title: "\(providerName(provider)) 로그인",
                target: self,
                action: #selector(signIn(_:))
            )
            button.tag = provider.rawValue
            contentStack.addArrangedSubview(button)
        }

        contentStack.addArrangedSubview(
            SampleUIFactory.button(
                title: "최근 Provider 로그아웃",
                target: self,
                action: #selector(signOut)
            )
        )

        addSectionTitle("Naver 전용 WebView")
        addIntroduction(
            "Naver 로그인은 일반 signIn 함수가 아니라 이 화면이 소유한 WKWebView와 전용 공개 함수를 사용합니다."
        )
        naverWebView.backgroundColor = .secondarySystemBackground
        naverWebView.layer.cornerRadius = 10
        naverWebView.clipsToBounds = true
        naverWebView.accessibilityLabel = "Naver 로그인 WebView"
        contentStack.addArrangedSubview(naverWebView)
        naverWebView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        addResultSection()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(renderDescriptors),
            name: .sampleStateDidChange,
            object: nil
        )
        renderDescriptors()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func renderDescriptors() {
        guard SampleStateStore.shared.isAuthReady else {
            descriptorLabel.text = "SNS Login 모듈 초기화 대기 또는 설정 필요"
            return
        }

        let descriptors = AppBox.getAuthProviderDescriptors()
        descriptorLabel.text = providers.map { provider in
            let configured = descriptors.first(where: { $0.type == provider })?.configured ?? false
            return "\(providerName(provider)): \(configured ? "설정됨" : "설정 필요")"
        }.joined(separator: "\n")
    }

    @objc private func signIn(_ sender: UIButton) {
        guard let provider = AppBoxAuthProvider(rawValue: sender.tag) else { return }
        guard SampleConfiguration.canInitializeSDK else {
            showSettingsRequired("AppBox Project ID와 HTTPS Base URL을 먼저 설정하세요.")
            return
        }
        guard SampleStateStore.shared.isAuthReady,
              AppBox.isAuthAvailable(provider) else {
            showSettingsRequired("\(providerName(provider)) 로그인 runtime이 준비되지 않았습니다.")
            return
        }
        let descriptor = AppBox.getAuthProviderDescriptors().first { $0.type == provider }
        guard descriptor?.configured == true else {
            showSettingsRequired("\(providerName(provider)) 외부 Console 값과 앱 설정을 확인하세요.")
            return
        }

        if provider == .naver {
            AppBox.signInWithNaver(webView: naverWebView, callId: nil) { user, error in
                self.handleSignIn(provider: provider, user: user, error: error)
            }
        } else {
            AppBox.signIn(provider, presentingViewController: self) { user, error in
                self.handleSignIn(provider: provider, user: user, error: error)
            }
        }
    }

    @objc private func signOut() {
        guard let provider = lastSignedInProvider else {
            setResult("이 화면에서 완료된 로그인 기록이 없습니다.", isError: true)
            return
        }
        AppBox.signOut(provider) { success, error in
            if success {
                self.lastSignedInProvider = nil
                self.setResult("\(self.providerName(provider)) 로그아웃이 완료되었습니다.")
                SampleStateStore.shared.record(
                    category: "SNS Login",
                    message: "\(self.providerName(provider)) 로그아웃 완료"
                )
            } else {
                self.setResult(
                    error?.localizedDescription ?? "로그아웃에 실패했습니다.",
                    isError: true
                )
            }
        }
    }

    private func handleSignIn(
        provider: AppBoxAuthProvider,
        user: AppBoxUserAuthData?,
        error: NSError?
    ) {
        guard user != nil, error == nil else {
            setResult(
                error?.localizedDescription ?? "로그인에 실패했습니다.",
                isError: true
            )
            return
        }
        lastSignedInProvider = provider
        setResult("\(providerName(provider)) 로그인이 완료되었습니다. 사용자 정보는 표시하지 않습니다.")
        SampleStateStore.shared.record(
            category: "SNS Login",
            message: "\(providerName(provider)) 로그인 완료"
        )
    }

    private func providerName(_ provider: AppBoxAuthProvider) -> String {
        switch provider {
        case .google: return "Google"
        case .apple: return "Apple"
        case .kakao: return "Kakao"
        case .naver: return "Naver"
        @unknown default: return "Unknown"
        }
    }
}
