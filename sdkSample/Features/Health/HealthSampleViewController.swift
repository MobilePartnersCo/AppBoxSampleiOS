import UIKit
import AppBoxSDK

final class HealthSampleViewController: SampleFeatureViewController {
    private let fromDateField = SampleUIFactory.textField(placeholder: "시작일 · yyyy-MM-dd")
    private let toDateField = SampleUIFactory.textField(placeholder: "종료일 · yyyy-MM-dd")
    private let healthTimeZone = TimeZone(identifier: "Asia/Seoul") ?? .current

    private lazy var healthCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = healthTimeZone
        return calendar
    }()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = healthCalendar
        formatter.timeZone = healthTimeZone
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HealthKit"
        addIntroduction(
            "HealthKit Capability와 읽기 권한이 필요합니다. 조회 함수가 필요한 읽기 권한을 요청하며, 결과 원문은 공용 이벤트 로그에 저장하지 않습니다."
        )
        setDefaultDates()
        contentStack.addArrangedSubview(fromDateField)
        contentStack.addArrangedSubview(toDateField)
        contentStack.addArrangedSubview(
            SampleUIFactory.button(
                title: "걸음 수 조회",
                target: self,
                action: #selector(loadSteps)
            )
        )
        addResultSection()
    }

    @objc private func loadSteps() {
        guard SampleConfiguration.canInitializeSDK else {
            showSettingsRequired("AppBox Project ID와 HTTPS Base URL을 먼저 설정하세요.")
            return
        }
        guard SampleStateStore.shared.isHealthReady, AppBox.isHealthAvailable() else {
            showSettingsRequired("Health runtime과 실제 기기의 HealthKit 지원 상태를 확인하세요.")
            return
        }

        let fromText = fromDateField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let toText = toDateField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let fromDate = exactDate(fromText),
              let toDate = exactDate(toText),
              fromDate <= toDate else {
            setResult("날짜를 yyyy-MM-dd 형식으로 입력하고 시작일이 종료일보다 늦지 않게 하세요.", isError: true)
            return
        }

        AppBox.getHealthSteps(fromDate: fromText, toDate: toText) { steps, error in
            if let error {
                let code = AppBoxHealthErrorCode(rawValue: error.code) ?? .unknown
                self.setResult("Health 조회 실패: \(self.errorDescription(code))", isError: true)
                return
            }

            let values = steps ?? []
            let text = values.isEmpty
                ? "조회된 걸음 수가 없습니다."
                : values.map { "\($0.date): \($0.step)걸음" }.joined(separator: "\n")
            self.setResult(text)
            SampleStateStore.shared.record(
                category: "Health",
                message: "Health 조회를 완료했습니다. 데이터 원문은 로그에 저장하지 않았습니다."
            )
        }
    }

    private func setDefaultDates() {
        let endDate = Date()
        let startDate = healthCalendar.date(
            byAdding: .day,
            value: -6,
            to: endDate
        ) ?? endDate
        fromDateField.text = dateFormatter.string(from: startDate)
        toDateField.text = dateFormatter.string(from: endDate)
    }

    private func exactDate(_ text: String) -> Date? {
        guard let date = dateFormatter.date(from: text),
              dateFormatter.string(from: date) == text else {
            return nil
        }
        return date
    }

    private func errorDescription(_ code: AppBoxHealthErrorCode) -> String {
        switch code {
        case .invalidDate: return "날짜 형식이 올바르지 않습니다."
        case .invalidRange: return "조회 기간이 올바르지 않습니다."
        case .permissionDenied: return "Health 읽기 권한이 허용되지 않았습니다."
        case .featureUnavailable: return "Health 기능이 초기화되지 않았습니다."
        case .notSupported: return "현재 기기에서 지원되지 않습니다."
        case .serviceUnavailable: return "Health 서비스를 사용할 수 없습니다."
        case .unknown: return "알 수 없는 오류입니다."
        @unknown default: return "알 수 없는 오류입니다."
        }
    }
}
