import UIKit
import TodoListPackage

protocol TodoItemDetailsViewControllerDelegate: AnyObject {
    func didUpdateData()
}


class TodoItemDetailsViewController: UIViewController {
    
    weak var delegate: TodoItemDetailsViewControllerDelegate?
    
    private var taskId: String? = nil
    private let fileCache = FileCache.shared
    private let databaseCache = DatabaseCache.shared
    let coreDataCache = CoreDataCache.shared

    
    var currentTask: TodoItem?
    
    private var saveButton: UIBarButtonItem?

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                textView,
                detailsView,
                deleteButton
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.delegate = self
        deleteButton.addTarget(self, action: #selector(deleteTodoItem), for: .touchUpInside)
        
        return stackView
    }()
    
    private lazy var textView = TodoItemTextView()
    
    private lazy var detailsView = TodoItemDetailsView()
    
    private lazy var deleteButton = TodoItemDeleteButtonView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObservers()
        
        let tapForHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapForHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapForHideKeyboard)
        
        setup()
        loadTodoItem()
    }

    private func setup() {
        setupNavigationBar()
        
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        setupColors()
        setupConstraints()
    }
    
    private func loadTodoItem() {
        guard let currentTask
        else {
            enableNavBarSaveButton(isEnabled: false)
            return
        }
        
        textView.setTaskName(name: currentTask.text)
        detailsView.importanceView.setTaskImportance(importance: currentTask.importance)
        detailsView.deadlineView.setTaskDeadline(deadline: currentTask.deadline)
        detailsView.colorPicker.setTaskColor(color:  (currentTask.color ?? Colors.labelPrimary?.hex!)!)
        enableNavBarSaveButton(isEnabled: true)
        deleteButton.isEnabled = true
    }

    private func setupNavigationBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: view.bounds.size.width,
                                                   height: UINavigationController().navigationBar.frame.size.height))

        navBar.barTintColor = Colors.backPrimary
        navBar.isTranslucent = false
        
        let navItem = UINavigationItem(title: "Дело")
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: Fonts.headline]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        navigationItem.title = "Дело"

        let cancelButton = UIBarButtonItem(title: "Отменить",
                                           style: .plain,
                                           target: self,
                                           action: #selector(back))
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.body], for: .normal)
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.body], for: .highlighted)
        navItem.leftBarButtonItem = cancelButton

        let saveButton = UIBarButtonItem(title: "Сохранить",
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.saveTodoItem))
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.headline], for: .normal)
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.headline], for: .highlighted)
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.headline], for: .disabled)
        navItem.rightBarButtonItem = saveButton
        self.saveButton = saveButton
        
        navBar.items = [navItem]
        
        self.view.addSubview(navBar)
    }
    
    private func setupColors() {
        view.backgroundColor = Colors.backPrimary
        textView.backgroundColor = Colors.backSecondary
    }

    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UINavigationController().navigationBar.frame.size.height),
                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
        NSLayoutConstraint.activate(
            [
                mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 28),
                mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
            ]
        )
        NSLayoutConstraint.activate(
            [
                textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
            ]
        )
    }
    
    @objc private func saveTodoItem() {
        guard let text = textView.getTaskName(),
              let importance = detailsView.importanceView.getTaskImportance()
        else { return }
        let deadline = detailsView.deadlineView.getTaskDeadline()
        let color = detailsView.colorPicker.getTaskColor()
        
        let todoItem: TodoItem
        
        if let curItem = currentTask {
            todoItem = TodoItem(id: curItem.id,
                                    text: text,
                                    importance: importance,
                                    deadline: deadline,
                                    done: curItem.done,
                                    created_at: curItem.created_at,
                                    changed_at: .now,
                                    color: color)
            //MARK: - SQLITE
            //databaseCache.updateTodoItem(todoItem)
            //MARK: - COREDATA
            coreDataCache.updateTodoItem(todoItem)
        }
        else {
            todoItem = TodoItem(text: text, importance: importance, deadline: deadline, color: color)
            //MARK: - SQLITE
            //databaseCache.insertTodoItem(todoItem)
            //MARK: - COREDATA
            coreDataCache.insertTodoItem(todoItem)
            
        }
        
        //MARK: - FILECACHE
        
        //fileCache.addChangeTodoItem(todoItem)
        
        delegate?.didUpdateData()
        dismiss(animated: true)
    }
    
    @objc private func deleteTodoItem() {
        guard let id = currentTask?.id
        else { return }
        
        //MARK: - FILECACHE
        //fileCache.removeTodoItem(withID: id)
        
        //MARK: - SQLITE
        //databaseCache.removeTodoItem(withID: id)
        
        //MARK: - COREDATA
        coreDataCache.removeTodoItem(withID: id)
        
        
        textView.setTaskName(name: "")
        detailsView.importanceView.setTaskImportance(importance: .important)
        detailsView.deadlineView.setTaskDeadline(deadline: nil)
        detailsView.colorPicker.setTaskColor(color: (Colors.labelPrimary?.hex!)!)
        enableNavBarSaveButton(isEnabled: false)
        delegate?.didUpdateData()
        dismiss(animated: true)
    }
    
    func enableNavBarSaveButton(isEnabled: Bool) {
        saveButton?.isEnabled = isEnabled
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let nsValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        
        let keyboardSize = nsValue.cgRectValue
        let contentInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardSize.height,
            right: 0
        )
        scrollView.contentInset = contentInsets
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = contentInsets
    }
    
    @objc private func back() {
        delegate?.didUpdateData()
        dismiss(animated: true)
    }

}


extension TodoItemDetailsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Что надо сделать?" && textView.textColor == Colors.labelTertiary {
            textView.text = ""
            textView.textColor = Colors.labelPrimary
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Что надо сделать?"
            textView.textColor = Colors.labelTertiary
            enableNavBarSaveButton(isEnabled: false)
        } else {
            textView.resignFirstResponder()
            enableNavBarSaveButton(isEnabled: true)
        }

    }

}
