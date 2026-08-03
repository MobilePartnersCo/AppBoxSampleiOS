//
//  NotificationService.swift
//  appBoxNotiServiceExtension
//
//  Created by mobilePartners on 6/10/25.
//

import Foundation
import UserNotifications
import AppBoxPushSDK

final class NotificationService: UNNotificationServiceExtension {
    private let completionLock = NSLock()
    private var didComplete = false
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var fallbackContent: UNNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        completionLock.lock()
        didComplete = false
        self.contentHandler = contentHandler
        fallbackContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
            ?? request.content
        completionLock.unlock()

        // 수신 queue 기록은 main app에서 중복 호출하지 않습니다.
        AppBoxPush.shared.recordNotificationReceived(request)
        AppBoxPush.shared.recordJourneyPushReceived(request)
        AppBoxPush.shared.recordPushDelivered(request)

        // queue 기록 이후 payload의 이미지 URL을 내려받아 rich push content로 변환합니다.
        AppBoxPush.shared.createFCMImage(request) { [self] content in
            complete(with: content)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        complete(with: nil)
    }

    private func complete(with content: UNNotificationContent?) {
        completionLock.lock()
        guard !didComplete,
              let contentHandler,
              let resolvedContent = content ?? fallbackContent else {
            completionLock.unlock()
            return
        }

        didComplete = true
        self.contentHandler = nil
        fallbackContent = nil
        completionLock.unlock()

        contentHandler(resolvedContent)
    }
}
