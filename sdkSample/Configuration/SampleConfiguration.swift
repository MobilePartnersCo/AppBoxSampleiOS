import Foundation

struct SampleSetting {
    let name: String
    let displayValue: String
    let source: String
    let isConfigured: Bool
}

enum SampleConfiguration {
    // AppBox Console > 프로젝트 설정
    static let projectID = "<APPBOX_PROJECT_ID>"
    static let baseURLString = "https://<APPBOX_BASE_URL>"

    // Firebase Console > OAuth 2.0 Client ID
    static let firebaseClientID = "<FIREBASE_OAUTH_CLIENT_ID>"

    // Kakao Developers > 앱 키
    static let kakaoNativeAppKey = "<KAKAO_NATIVE_APP_KEY>"

    // Naver Developers > 애플리케이션 정보
    static let naverAppName = "<NAVER_APP_NAME>"
    static let naverClientID = "<NAVER_CLIENT_ID>"
    static let naverClientSecret = "<NAVER_CLIENT_SECRET>"
    static let naverURLScheme = "<NAVER_URL_SCHEME>"

    // AppBox Console > 사용자 여정 / 전환
    static let journeyEventKeyExample = "<JOURNEY_EVENT_KEY>"
    static let conversionCodeExample = "<CONVERSION_CODE>"

    // AppsFlyer Dashboard > App Settings
    static let appsFlyerDevKey = "<APPSFLYER_DEV_KEY>"
    static let appsFlyerAppleAppID = "<APPLE_APP_ID>"

    static let debugMode = true
    static let appleLoginEnabled = true

    static var canInitializeSDK: Bool {
        isConfigured(projectID) && validBaseURLString != nil
    }

    static var validBaseURLString: String? {
        guard isConfigured(baseURLString),
              let url = URL(string: baseURLString),
              url.scheme?.lowercased() == "https",
              let host = url.host,
              !host.isEmpty else {
            return nil
        }
        return baseURLString
    }

    static var hasGoogleLoginConfiguration: Bool {
        isConfigured(firebaseClientID)
    }

    static var hasKakaoLoginConfiguration: Bool {
        isConfigured(kakaoNativeAppKey)
    }

    static var hasNaverLoginConfiguration: Bool {
        [
            naverAppName,
            naverClientID,
            naverClientSecret,
            naverURLScheme
        ].allSatisfy(isConfigured)
    }

    static var hasAppsFlyerConfiguration: Bool {
        isConfigured(appsFlyerDevKey) && isConfigured(appsFlyerAppleAppID)
    }

    static var settings: [SampleSetting] {
        [
            setting(
                name: "AppBox Project ID",
                value: projectID,
                source: "AppBox Console > 프로젝트 설정",
                isSecret: false
            ),
            setting(
                name: "Base URL",
                value: baseURLString,
                source: "AppBox Console 또는 구축 환경 담당자",
                isSecret: false,
                extraValidation: validBaseURLString != nil
            ),
            setting(
                name: "Firebase OAuth Client ID",
                value: firebaseClientID,
                source: "Firebase Console > Authentication",
                isSecret: true
            ),
            setting(
                name: "Kakao Native App Key",
                value: kakaoNativeAppKey,
                source: "Kakao Developers > 앱 키",
                isSecret: true
            ),
            SampleSetting(
                name: "Apple Sign In",
                displayValue: "코드 활성화 · Capability 확인 필요",
                source: "Xcode > Signing & Capabilities",
                isConfigured: appleLoginEnabled
            ),
            SampleSetting(
                name: "Naver Login",
                displayValue: hasNaverLoginConfiguration ? "설정됨" : "미설정",
                source: "Naver Developers > 애플리케이션 정보",
                isConfigured: hasNaverLoginConfiguration
            ),
            SampleSetting(
                name: "AppsFlyer",
                displayValue: hasAppsFlyerConfiguration ? "설정됨" : "미설정",
                source: "AppsFlyer Dashboard > App Settings",
                isConfigured: hasAppsFlyerConfiguration
            )
        ]
    }

    static func isConfigured(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let uppercased = trimmed.uppercased()
        return !trimmed.contains("<")
            && !trimmed.contains(">")
            && !uppercased.hasPrefix("YOUR_")
            && !uppercased.contains("PLACEHOLDER")
    }

    private static func setting(
        name: String,
        value: String,
        source: String,
        isSecret: Bool,
        extraValidation: Bool = true
    ) -> SampleSetting {
        let configured = isConfigured(value) && extraValidation
        let displayValue: String

        if !configured {
            displayValue = "미설정"
        } else if isSecret {
            displayValue = "설정됨"
        } else if name == "Base URL", let host = URL(string: value)?.host {
            displayValue = host
        } else {
            displayValue = masked(value)
        }

        return SampleSetting(
            name: name,
            displayValue: displayValue,
            source: source,
            isConfigured: configured
        )
    }

    private static func masked(_ value: String) -> String {
        guard value.count > 6 else { return "설정됨" }
        return "\(value.prefix(3))•••\(value.suffix(3))"
    }
}
