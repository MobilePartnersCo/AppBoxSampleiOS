
# AppBoxSDK 문서

[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-green.svg)](https://swift.org/package-manager/)

---

### 설치 방법

AppBoxSDK는 [Swift Package Manager](https://swift.org/package-manager/)를 통해 배포됩니다. 프로젝트에 통합하려면 다음 단계를 따라주세요:

1. Xcode에서 **File > Add Packages...** 선택
2. 다음 SPM URL 입력:
   ```console
   https://bitbucket.org/insystems_moon/waveappsuite_public_sdk_ios
   ```
3. **Dependency Rule** to be `Up to Next Major Version`.

---

### Info.plist 설정

SDK를 사용하려면 `Info.plist` 파일에 아래와 같은 항목을 추가하세요:

```xml
<key>NSFaceIDUsageDescription</key>
<string>생체인증을 사용하기 위해 필요합니다.</string>
<key>NSCameraUsageDescription</key>
<string>카메라를 사용하기 위해 필요합니다.</string>
<key>NSHealthShareUsageDescription</key>
<string>걸음수를 가져오기 위해 필요합니다.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>걸음수를 가져오기 위해 필요합니다.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>위치정보 제공을 위해 필요합니다.</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

---

### 주요 기능

#### **SDK 초기화**

```swift
appBox.initSDK(baseUrl: "https://example.com", webConfig: config, debugMode: true)
```

#### **AppBoxIntro**
- 앱의 인트로 화면을 노출합니다.

```swift
let intro = AppBoxIntro(imageUrl: "https://example.com/image.jpg")
appBox.setIntro([intro])
```

#### **푸시 알림 관리**
- 푸시 알림에 사용할 푸시토큰을 설정합니다.

```swift
appBox.setPushToken("your-push-token")
```

#### **WebView 설정**
- 애플리케이션의 `WKWebView` 설정을 사용자화합니다.

```swift
let webConfig = AppBoxWebConfig()
webConfig.customUserAgent = "MyCustomUserAgent"
appBox.initSDK(baseUrl: "https://example.com", webConfig: webConfig)
```

#### **SDK Start**
- `UIViewController`받아 SDK에 화면을 호출합니다.

```swift
appBox.start(from: viewController) { success, error in
    if success {
        print("App started successfully.")
    } else {
        print("Failed to start: \(error?.localizedDescription ?? "Unknown error")")
    }
}
```

### 사용 예시

#### **초기화**

```swift
import AppBoxSDK

let appBox = AppBox.shared
let webConfig = AppBoxWebConfig()
webConfig.customUserAgent = "MyCustomUserAgent"

appBox.initSDK(baseUrl: "https://example.com", webConfig: webConfig, debugMode: true)
```

#### **인트로 화면**

```swift
if let intro = AppBoxIntro(imageUrl: "https://example.com/image.jpg") {
    appBox.setIntro([intro])
} else {
    print("Failed to initialize AppBoxIntro.")
}
```

#### **앱 실행**

```swift
appBox.start(from: viewController) { success, error in
    if success {
        print("App started successfully!")
    } else {
        print("Error starting app: \(error?.localizedDescription ?? "Unknown error")")
    }
}
```

---

### 요구 사항

- **iOS** 13.0 이상
- **Xcode** 14.0 이상
- **Swift Package Manager** 호환

---

### 라이선스

`AppBoxSDK`는 독점 소프트웨어입니다. 명시적인 허가 없이 재배포나 수정이 금지됩니다. 문의 사항은 [support@example.com](mailto:support@example.com)으로 연락 바랍니다.
