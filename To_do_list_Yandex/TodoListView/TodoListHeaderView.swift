import UIKit

protocol TodoListHeaderViewDelegate: AnyObject {
    func todoListHeaderView(
        _ view: TodoListHeaderView,
        didSelectShowButton isSelected: Bool
    )
}

final class TodoListHeaderView: UIView {
    weak var delegate: TodoListHeaderViewDelegate?
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private lazy var titleLabel = makeTitleLabel()
    private lazy var showButton = makeShowButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    @objc
    private func didTapShowButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        delegate?.todoListHeaderView(self, didSelectShowButton: sender.isSelected)
    }

    private func configureColors() {
        titleLabel.textColor = Colors.labelTertiary
        showButton.setTitleColor(Colors.colorBlue, for: .normal)
    }

    private func setup() {
        [titleLabel, showButton].forEach { addSubview($0) }
        translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
        configureColors()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        NSLayoutConstraint.activate([
            showButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            showButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16),
            showButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            showButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])

    }
    
    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.subhead
        return label
    }
    
    private func makeShowButton() -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapShowButton), for: .touchUpInside)
        button.isSelected = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Показать", for: .normal)
        button.setTitle("Скрыть", for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return button
    }
}
