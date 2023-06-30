import UIKit

final class DividerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.supportSeparator
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


}
