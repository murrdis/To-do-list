import UIKit

class TodoItemDetailsViewController: UIViewController {
    private var taskId: String? = nil
    private let fileCache = FileCache.fileCacheObj
    


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
        guard let todoItem = loadTodoItemFromFile()
        else {
            enableNavBarSaveButton(isEnabled: false)
            return
        }
        taskId = todoItem.id
        textView.setTaskName(name: todoItem.text)
        detailsView.importanceView.setTaskImportance(importance: todoItem.importance)
        detailsView.deadlineView.setTaskDeadline(deadline: todoItem.deadline)
        detailsView.colorPicker.setTaskColor(color:  todoItem.hexColor!)
        enableNavBarSaveButton(isEnabled: true)
        deleteButton.isEnabled = true
    }

    private func setupNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: Fonts.headline]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        navigationItem.title = "Дело"

        let cancelButton = UIBarButtonItem(title: "Отменить",
                                           style: .plain,
                                           target: self,
                                           action: nil)
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.body], for: .normal)
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.body], for: .highlighted)
        navigationItem.leftBarButtonItem = cancelButton

        let saveButton = UIBarButtonItem(title: "Сохранить",
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.saveTodoItemToFile))
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.headline], for: .normal)
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.headline], for: .highlighted)
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.headline], for: .disabled)
        navigationItem.rightBarButtonItem = saveButton
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
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
        NSLayoutConstraint.activate(
            [
                mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
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
    
    @objc private func saveTodoItemToFile() {
        guard let text = textView.getTaskName(),
              let importance = detailsView.importanceView.getTaskImportance()
        else { return }
        let deadline = detailsView.deadlineView.getTaskDeadline()
        let color = detailsView.colorPicker.getTaskColor()
        if (taskId != nil) {
            let todoItem = TodoItem(id: taskId!, text: text, importance: importance, deadline: deadline, hexColor: color)
            fileCache.addTodoItem(todoItem)
        }
        else {
            let todoItem = TodoItem(text: text, importance: importance, deadline: deadline, hexColor: color)
            fileCache.addTodoItem(todoItem)
        }
        
        fileCache.saveJsonToFile("TodoItems")
    }
    
    @objc private func deleteTodoItem() {
        guard let id = taskId
        else { return }
        
        fileCache.removeTodoItem(withID: id)
        fileCache.saveJsonToFile("TodoItems")
        
        textView.setTaskName(name: "")
        detailsView.importanceView.setTaskImportance(importance: .important)
        detailsView.deadlineView.setTaskDeadline(deadline: nil)
        detailsView.colorPicker.setTaskColor(color: (Colors.labelPrimary?.hex!)!)
        enableNavBarSaveButton(isEnabled: false)
    }
    
    private func loadTodoItemFromFile() -> TodoItem? {
        fileCache.loadJsonFromFile("TodoItems")
        guard fileCache.todoItems.count > 0 else { return nil }
        return fileCache.todoItems[0]
    }
    
    func enableNavBarSaveButton(isEnabled: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
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
        }
        textView.resignFirstResponder()
        enableNavBarSaveButton(isEnabled: true)
    }

}
