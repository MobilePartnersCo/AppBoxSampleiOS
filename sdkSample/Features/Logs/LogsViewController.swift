import UIKit

final class LogsViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "정제 이벤트 로그"
        view.backgroundColor = .systemGroupedBackground
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
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
            selector: #selector(reloadLogs),
            name: .sampleStateDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func reloadLogs() {
        tableView.reloadData()
    }
}

extension LogsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SampleStateStore.shared.logs.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "LogCell")
        let entry = SampleStateStore.shared.logs[indexPath.row]
        let timestamp = dateFormatter.string(from: entry.date)
        cell.textLabel?.text = "[\(entry.category)] \(entry.message)"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.detailTextLabel?.text = timestamp
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .caption1)
        cell.detailTextLabel?.adjustsFontForContentSizeCategory = true
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        cell.accessibilityLabel = "\(entry.category), \(entry.message), \(timestamp)"
        return cell
    }
}
