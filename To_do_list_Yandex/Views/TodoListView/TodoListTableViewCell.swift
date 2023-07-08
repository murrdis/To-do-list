import UIKit
import TodoListPackage

class TodoListTableViewCell: UITableViewCell {
    
    let divider = DividerView()
    private let fileCache = FileCache.fileCacheObj
    
    var currItem = TodoItem(text: "")
    
    private lazy var chevronImageView: UIImageView = {
        let chevronImageView = UIImageView(image: Images.chevron)
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        return chevronImageView
    }()
    
    private lazy var radioButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(isTodoItemDone), for: .touchUpInside)
        button.setImage(Images.radioButtonOn, for: .selected)
        button.setImage(Images.radioButtonOff, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var vStackView: UIStackView = {
        let vStackView = UIStackView(
            arrangedSubviews: [
                titleStackView,
                deadlineStackView
            ])
        deadlineStackView.isHidden = true
        vStackView.alignment = .leading
        vStackView.axis = .vertical
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        return vStackView
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                highPriorityImageView,
                taskLabel
            ])
        highPriorityImageView.isHidden = true
        stackView.axis = .horizontal
        
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var highPriorityImageView = UIImageView(image: Images.priorityHigh)

    private lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body
        label.textColor = Colors.labelPrimary
        label.numberOfLines = 3
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineStackView: UIStackView = {
        let calendarImageView = UIImageView(image: Images.calendar)
        calendarImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        calendarImageView.tintColor = Colors.labelTertiary
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let deadlineStackView = UIStackView(
            arrangedSubviews: [
                calendarImageView,
                deadlineLabel
            ])
        deadlineStackView.spacing = 2
        deadlineStackView.translatesAutoresizingMaskIntoConstraints = false
        return deadlineStackView
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let deadlineLabel = UILabel()
        deadlineLabel.font = Fonts.subhead
        deadlineLabel.textColor = Colors.labelTertiary
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        return deadlineLabel
    }()
    
    func setLastCell() {
        radioButton.isHidden = true
        taskLabel.text = "Новое"
        taskLabel.font = Fonts.body
        taskLabel.textColor = Colors.labelTertiary
        chevronImageView.isHidden = true
        divider.isHidden = true
    }
    
    @objc private func isTodoItemDone() {
//        let newItem = currItem.copy(done: !currItem.done)
//        fileCache.addChangeTodoItem(newItem)
//        currItem = newItem
//        if currItem.done {
//            radioButton.isSelected = true
//            taskLabel.textColor = Colors.labelTertiary
//            let attributedString = NSAttributedString(string: currItem.text, attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
//            taskLabel.attributedText = attributedString
//        } else {
//            radioButton.isSelected = false
//            taskLabel.attributedText = NSAttributedString(string: currItem.text)
//            taskLabel.textColor = Colors.labelPrimary
//            if (currItem.hexColor != nil) {
//                taskLabel.textColor = UIColor(hex: currItem.hexColor!)
//            }
//        }
        
    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        setupConstraints()
    }
    
    private func setup() {
        contentView.addSubview(radioButton)
        contentView.addSubview(vStackView)
        contentView.addSubview(chevronImageView)
        contentView.addSubview(divider)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            radioButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            radioButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            radioButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            vStackView.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 12),
            vStackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            vStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            chevronImageView.leadingAnchor.constraint(greaterThanOrEqualTo: vStackView.trailingAnchor, constant: 16),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 52),
            divider.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }

    
    func configure(with todoItem: TodoItem) {
        currItem = todoItem
        if todoItem.importance == .important {
            radioButton.setImage(Images.radioButtonHighPriority, for: .normal)
            highPriorityImageView.isHidden = false
        }
        
        taskLabel.text = todoItem.text
        
        if (todoItem.color != nil) {
            taskLabel.textColor = UIColor(hex: todoItem.color!)
        }
        
        if todoItem.deadline != nil {
            deadlineStackView.isHidden = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM"
            dateFormatter.locale = Locale(identifier: "ru")

            deadlineLabel.text = dateFormatter.string(from: todoItem.deadline!)
        }
        
        if todoItem.done {
            radioButton.isSelected = true
            taskLabel.textColor = Colors.labelTertiary
            let attributedString = NSAttributedString(string: todoItem.text, attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            taskLabel.attributedText = attributedString
        }
        
        
    }

    
    required init?(coder: NSCoder) {
        nil
    }

}
