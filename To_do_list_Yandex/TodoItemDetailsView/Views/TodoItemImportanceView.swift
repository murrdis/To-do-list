import UIKit
import TodoListPackage

final class TodoItemImportanceView: UIStackView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        axis = .horizontal
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addArrangedSubview(importanceLabel)
        addArrangedSubview(importanceControl)
    }
    
    private let importanceLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body
        label.text = "Важность"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let importanceControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.insertSegment(with: UIImage(named: "priority_low"), at: 0, animated: false)
        control.insertSegment(withTitle: "нет", at: 1, animated: false)
        control.insertSegment(with: UIImage(named: "priority_high"), at: 2, animated: false)
        control.selectedSegmentIndex = 2
        control.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        return control
    }()
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func getTaskImportance() -> TodoItem.Importance? {
        if importanceControl.selectedSegmentIndex == 0 {
            return TodoItem.Importance.notImportant
        } else if importanceControl.selectedSegmentIndex == 1 {
            return TodoItem.Importance.normal
        } else {
            return TodoItem.Importance.important
        }
    }
    
    func setTaskImportance(importance: TodoItem.Importance) {
        if importance == TodoItem.Importance.notImportant {
            importanceControl.selectedSegmentIndex = 0
        } else if importance == TodoItem.Importance.normal {
            importanceControl.selectedSegmentIndex = 1
        } else {
            importanceControl.selectedSegmentIndex = 2
        }
    }

}
