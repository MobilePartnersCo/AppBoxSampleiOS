//
//  NotificationService.swift
//  appBoxNotiServiceExtension
//
//  Created by mobilePartners on 6/10/25.
//

import UserNotifications
import AppBoxPushSDK

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        // [선택: Rich Push] 제한 시간 초과 시 원본 알림을 전달할 수 있도록 mutable copy를 보관합니다.
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // [선택: Rich Push] AppBoxPushSDK가 payload의 이미지 URL을 내려받아 rich push content로 변환합니다.
        AppBoxPush.shared.createFCMImage(request, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // [선택: Rich Push] Extension 종료 직전에 호출되므로, 변환이 끝나지 않았으면 보관한 알림을 그대로 전달합니다.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
