import UIKit

class TodoItemTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        invalidateIntrinsicContentSize()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        newSize.width = size.width
        return newSize
    }
    
    private func setup() {
        font = Fonts.body
        text = "Что надо сделать?"
        textColor = Colors.labelTertiary
        isScrollEnabled = false
        layer.cornerRadius = 16
        textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func getTaskName() -> String? {
        if text == "Что надо сделать?" && textColor == Colors.labelTertiary {
            return nil
        }
        
        return text
    }
    
    func setTaskName(name: String) {
        if text != ""  {
            textColor = Colors.labelPrimary
            self.text = name
        } else {
            textColor = Colors.labelTertiary
            self.text = "Что надо сделать?"
        }
    }
    
}



