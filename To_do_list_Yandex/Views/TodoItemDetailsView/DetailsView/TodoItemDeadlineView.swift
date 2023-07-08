import UIKit

final class TodoItemDeadlineView: UIStackView {
    private var deadline: Date? = nil
    
    func getTaskDeadline() -> Date? {
        return deadline
    }
    
    func setTaskDeadline(deadline: Date?) {
        if let date = deadline {
            self.deadline = date
            deadlineSwitch.isOn = true
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            deadlineButton.setTitle(dateFormatter.string(from: deadline!), for: .normal)
            
        }
        else {
            deadlineSwitch.isOn = false
            deadlineButton.setTitle("", for: .normal)
        }
    }
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.font = Fonts.body
        label.textColor = Colors.labelPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let deadlineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.titleLabel?.font = Fonts.footnote
        button.setTitleColor(Colors.colorBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(openCalendar), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func openCalendar() {
        guard deadlineSwitch.isOn else { return }
        UIView.animate(withDuration: 0.5) {
            self.calendarView.isHidden.toggle()
        }
    }
    
    private lazy var calendarView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            DividerView(),
            calendar
        ])
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins.top = 10
        stack.isHidden = true
        return stack
    }()
    
    private let calendar: UICalendarView = {
        let calendar = UICalendarView()
        calendar.availableDateRange = DateInterval(start: .now, end: Date.distantFuture)
        
        return calendar
    }()
    
    private let deadlineSwitch: UISwitch = {
        let deadlineSwitch = UISwitch()
        deadlineSwitch.addTarget(self, action: #selector(setDeadline), for: .valueChanged)
        return deadlineSwitch
    }()
    
    @objc private func setDeadline(deadlineSwitch: UISwitch) {
        if deadlineSwitch.isOn {
            deadline = Calendar.current.date(byAdding: .day, value: 1, to: .now)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            deadlineButton.setTitle(dateFormatter.string(from: deadline!), for: .normal)
        }
        else {
            deadline = nil
            deadlineButton.setTitle("", for: .normal)
            
            UIView.animate(withDuration: 0.5) {
                self.calendarView.isHidden = true
            }
        }
    }
    
    private lazy var vDeadlineLabelStack: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                deadlineLabel,
                deadlineButton
            ]
        )
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var hDeadlineStack: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                vDeadlineLabelStack,
                deadlineSwitch
            ]
        )
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        axis = .vertical
        backgroundColor = .clear
        spacing = 10
        
        addArrangedSubview(hDeadlineStack)
        addArrangedSubview(calendarView)
        translatesAutoresizingMaskIntoConstraints = false
        
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendar.selectionBehavior = selection
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

}


extension TodoItemDeadlineView: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        deadline = dateComponents?.date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        deadlineButton.setTitle(formatter.string(from: deadline!), for: .normal)
        
        UIView.animate(withDuration: 0.5) {
            self.calendarView.isHidden.toggle()
        }
    }
}
