import UIKit

final class ViewController: UIViewController {
    private enum Feature: Int, CaseIterable {
        case status
        case swiftWebView
        case objectiveCWebView
        case push
        case inApp
        case health
        case auth
        case journey
        case attribution
        case logs

        var title: String {
            switch self {
            case .status: return "SDK 및 설정 상태"
            case .swiftWebView: return "WebView · Swift"
            case .objectiveCWebView: return "WebView · Objective-C"
            case .push: return "Push"
            case .inApp: return "Push 연계 In-App"
            case .health: return "HealthKit"
            case .auth: return "SNS 로그인"
            case .journey: return "사용자 여정 및 전환"
            case .attribution: return "AppsFlyer 및 딥링크"
            case .logs: return "정제 이벤트 로그"
            }
        }

        var detail: String {
            switch self {
            case .status: return "프로젝트 설정과 모듈 초기화 결과"
            case .swiftWebView: return "AppBox.start 공개 함수 예제"
            case .objectiveCWebView: return "동일 기능의 Objective-C 호출 예제"
            case .push: return "권한 요청, APNs 등록, callback 상태"
            case .inApp: return "Push가 준비된 상태에서 메시지 동기화"
            case .health: return "기간별 걸음 수 조회"
            case .auth: return "Google, Apple, Kakao, Naver"
            case .journey: return "Journey event와 conversion 기록"
            case .attribution: return "설정 상태와 정제된 딥링크 결과"
            case .logs: return "민감정보를 제외한 최근 이벤트"
            }
        }
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AppBox SDK"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .systemGroupedBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stateDidChange),
            name: .sampleStateDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func stateDidChange() {
        tableView.reloadData()
    }

    private func makeViewController(for feature: Feature) -> UIViewController {
        switch feature {
        case .status:
            return StatusViewController()
        case .swiftWebView:
            return WebViewSampleViewController()
        case .objectiveCWebView:
            if let viewControllerType = NSClassFromString("ObjcViewController") as? UIViewController.Type {
                return viewControllerType.init()
            }
            let fallback = SampleFeatureViewController()
            fallback.title = "WebView · Objective-C"
            fallback.loadViewIfNeeded()
            fallback.addIntroduction("Objective-C 예제 화면을 생성하지 못했습니다.")
            fallback.setResult("Target Membership와 Objective-C 클래스 이름을 확인하세요.", isError: true)
            return fallback
        case .push:
            return PushSampleViewController()
        case .inApp:
            return InAppSampleViewController()
        case .health:
            return HealthSampleViewController()
        case .auth:
            return AuthSampleViewController()
        case .journey:
            return JourneySampleViewController()
        case .attribution:
            return AttributionStatusViewController()
        case .logs:
            return LogsViewController()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Feature.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "FeatureCell")
        guard let feature = Feature(rawValue: indexPath.row) else { return cell }

        cell.textLabel?.text = feature.title
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.detailTextLabel?.text = feature.detail
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        cell.detailTextLabel?.adjustsFontForContentSizeCategory = true
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityLabel = "\(feature.title), \(feature.detail)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let feature = Feature(rawValue: indexPath.row) else { return }
        navigationController?.pushViewController(
            makeViewController(for: feature),
            animated: true
        )
    }
}
