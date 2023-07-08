import UIKit

final class TodoItemDetailsView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    private func setup() {
        axis = .vertical
        backgroundColor = Colors.backSecondary
        layer.cornerRadius = 16
        spacing = 10
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        addArrangedSubview(importanceView)
        addArrangedSubview(DividerView())
        addArrangedSubview(deadlineView)
        addArrangedSubview(DividerView())
        addArrangedSubview(colorPicker)
        translatesAutoresizingMaskIntoConstraints = false

        setupConstraints()
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                topAnchor.constraint(equalTo: topAnchor),
                leadingAnchor.constraint(equalTo: leadingAnchor),
                trailingAnchor.constraint(equalTo: trailingAnchor),
                bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
    }
    
    var importanceView = TodoItemImportanceView()
    var deadlineView = TodoItemDeadlineView()
    var colorPicker = TodoItemColorPickerView()

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
