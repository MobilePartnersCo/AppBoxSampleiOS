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
        
    }

    @IBAction func start(_ sender: Any) {
        // -----------------------------------------------------------------------------------------
        // AppBox 실행
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

