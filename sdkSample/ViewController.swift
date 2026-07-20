//
//  ViewController.swift
//  sdkSample
//
//  Created by mobilePartners on 11/26/24.
//

import UIKit
import AppBoxSDK

class ViewController: UIViewController {

    @IBAction func start(_ sender: Any) {
        // -----------------------------------------------------------------------------------------
        // [AppBox 기본 WebView] AppBox 실행
        // 현재 ViewController 위에 AppBox 관리 WebView를 표시합니다.
        // -----------------------------------------------------------------------------------------
        AppBox.start(from: self) { isSuccess, error in
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
