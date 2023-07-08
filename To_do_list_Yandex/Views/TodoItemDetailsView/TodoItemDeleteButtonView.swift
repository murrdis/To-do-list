import UIKit

final class TodoItemDeleteButtonView: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        setTitle("Удалить", for: .normal)
        setTitleColor(Colors.colorRed, for: .normal)
        setTitleColor(Colors.labelTertiary, for: .disabled)
        titleLabel?.font = Fonts.body
        layer.cornerRadius = 16
        backgroundColor = Colors.backSecondary
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        isEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
