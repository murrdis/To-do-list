import UIKit

final class DividerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.supportSeparator
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


}
