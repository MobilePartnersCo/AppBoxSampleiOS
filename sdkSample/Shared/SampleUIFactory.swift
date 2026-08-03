import UIKit

enum SampleUIFactory {
    static func label(
        _ text: String? = nil,
        style: UIFont.TextStyle = .body,
        color: UIColor = .label
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    static func button(title: String, target: Any, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.layer.cornerRadius = 10
        button.backgroundColor = .secondarySystemBackground
        button.addTarget(target, action: action, for: .touchUpInside)
        button.accessibilityLabel = title
        return button
    }

    static func textField(
        placeholder: String,
        text: String? = nil
    ) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.borderStyle = .roundedRect
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.accessibilityLabel = placeholder
        return textField
    }

    static func card(title: String, value: String, detail: String? = nil) -> UIView {
        let titleLabel = label(title, style: .subheadline, color: .secondaryLabel)
        let valueLabel = label(value, style: .headline)
        valueLabel.accessibilityLabel = "\(title), \(value)"

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4

        if let detail {
            stack.addArrangedSubview(label(detail, style: .footnote, color: .secondaryLabel))
        }

        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        return container
    }
}

class SampleFeatureViewController: UIViewController {
    let contentStack = UIStackView()
    let resultLabel = SampleUIFactory.label(
        "아직 실행한 동작이 없습니다.",
        style: .body,
        color: .secondaryLabel
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 12
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    func addIntroduction(_ text: String) {
        contentStack.addArrangedSubview(
            SampleUIFactory.label(text, style: .body, color: .secondaryLabel)
        )
    }

    func addSectionTitle(_ text: String) {
        let label = SampleUIFactory.label(text, style: .title3)
        label.font = .preferredFont(forTextStyle: .title3).bold()
        contentStack.addArrangedSubview(label)
        contentStack.setCustomSpacing(6, after: label)
    }

    func addResultSection() {
        addSectionTitle("실행 결과")
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.addSubview(resultLabel)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            resultLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            resultLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            resultLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        contentStack.addArrangedSubview(container)
    }

    func setResult(_ text: String, isError: Bool = false) {
        let changes = {
            self.resultLabel.text = text
            self.resultLabel.textColor = isError ? .systemRed : .label
            self.resultLabel.accessibilityLabel = "실행 결과, \(text)"
        }
        if Thread.isMainThread {
            changes()
        } else {
            DispatchQueue.main.async(execute: changes)
        }
    }

    func showSettingsRequired(_ message: String) {
        setResult(message, isError: true)
        let alert = UIAlertController(
            title: "설정 필요",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

private extension UIFont {
    func bold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
