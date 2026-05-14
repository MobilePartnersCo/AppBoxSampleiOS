//
//  ViewController.swift
//  sdkSample
//
//  Created by mobilePartners on 11/26/24.
//

import UIKit
import AppBoxSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox BaseUrl 설정
        // initSDK의 baseUrl과 다르게 테스트할 때 화면 진입 시점에 override할 수 있습니다.
        // -----------------------------------------------------------------------------------------
        AppBox.shared.setBaseUrl(baseUrl: "https://www.example.com")
        // -----------------------------------------------------------------------------------------
        
        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox Debug 설정
        // 샘플에서는 로그 확인을 위해 켜두며, 운영 빌드에서는 false를 권장합니다.
        // -----------------------------------------------------------------------------------------
        AppBox.shared.setDebug(debugMode: true)
        // -----------------------------------------------------------------------------------------
    }

    @IBAction func start(_ sender: Any) {
        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox 실행
        // 현재 ViewController 위에 AppBox 관리 WebView를 표시합니다.
        // -----------------------------------------------------------------------------------------
        AppBox.shared.start(from: self) { isSuccess, error in
            if isSuccess {
                // 실행 성공 처리
                print("AppBox:: SDK 실행 성공")
            } else {
                // 실행 실패 처리
                if let error = error {
                    print("error : \(error.localizedDescription)")
                } else {
                    print("error : unkown Error")
                }
            }
        }
        // -----------------------------------------------------------------------------------------
    }
}

