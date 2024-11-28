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
        // AppBox SDK 시작
        // -----------------------------------------------------------------------------------------
        AppBox.shared.start(from: self) { isSuccess, error in
            if let error = error {
                print("error : \(error.localizedDescription)")
            }
        }
        // -----------------------------------------------------------------------------------------
    }
}

