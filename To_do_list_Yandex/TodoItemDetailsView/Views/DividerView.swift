import UIKit

final class DividerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        backgroundColor = Colors.supportSeparator
        heightAnchor.constraint(equalToConstant: 1).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
    }

}
