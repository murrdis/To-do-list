import UIKit
import Foundation
import TodoListPackage

class ViewController: UIViewController {
    
    let fileCache = FileCache.fileCacheObj
//    private var items: [TodoItem] = [] {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
    
    private var itemsWithoutDone = [
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Read a book", deadline: Date())
    ]
    
    private var itemsWithDone = [
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Read a book", deadline: Date())
    ]
    
    private var items = [
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Read a book", deadline: Date())
    ]
    
    private var shouldShowDoneTasks = false
    
    private lazy var headerView = TodoListHeaderView()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Colors.backPrimary
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .always
        return scrollView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                tableView
            ]
        )
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var doneLabelStackView: UIStackView = {
        let doneLabelStackView = UIStackView(
            arrangedSubviews: [
                
            ]
        )
        return doneLabelStackView
    }()

    
    
    private lazy var tableView: ContentSizedTableView = {
        let tableView = ContentSizedTableView()
        tableView.dataSource = self
        tableView.delegate = self
        headerView.delegate = self
        tableView.estimatedRowHeight = 56
        tableView.layer.cornerRadius = 16
        tableView.register(
            TodoListTableViewCell.self,
            forCellReuseIdentifier: "TodoListTableViewCell"
        )
        tableView.alwaysBounceVertical = false
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        button.setImage(Images.add, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileCache.loadJsonFromFile("TodoItems")
        itemsWithDone = fileCache.todoItems
        itemsWithoutDone = itemsWithDone.filter { $0.done == false }
        items = itemsWithoutDone
        
        setupNavBar()
        setup()

    }

    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins.top = 44
        navigationController?.navigationBar.layoutMargins.left = 32
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Colors.labelPrimary, .font: Fonts.largeTitle]
        navigationItem.title = "Мои дела"
        
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.titleTextAttributes = [.font: Fonts.headline]
        self.navigationController?.navigationBar.standardAppearance = compactAppearance
        self.navigationController?.navigationBar.compactAppearance = compactAppearance
        
        let largeAppearance = UINavigationBarAppearance()
        largeAppearance.backgroundColor = Colors.backPrimary
        largeAppearance.largeTitleTextAttributes = [.font: Fonts.largeTitle]
        largeAppearance.shadowColor = .clear
        self.navigationController?.navigationBar.scrollEdgeAppearance = largeAppearance
    }
    
    private func setup() {
        view.addSubview(scrollView)
        scrollView.addSubview(headerView)
        scrollView.addSubview(tableView)
        view.addSubview(addButton)
        headerView.title = "Выполнено — \(itemsWithDone.count-itemsWithoutDone.count)"
        setupConstraints()
        setupColors()
    }
    
    private func setupColors() {
        view.backgroundColor = Colors.backPrimary
        tableView.backgroundColor = Colors.backSecondary
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
        NSLayoutConstraint.activate(
            [
                headerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                headerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
                headerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -32)
            ]
        )
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                tableView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
            ]
        )
        NSLayoutConstraint.activate(
            [
                addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
    }
    
    @objc
    private func didTapAddButton(_ sender: UIButton) {
        let detailsVC = TodoItemDetailsViewController()
        detailsVC.delegate = self
        self.present(detailsVC, animated: true)
    }
    
    @objc
    private func showDoneTasks() {
        shouldShowDoneTasks.toggle()
        if shouldShowDoneTasks {
            items = itemsWithDone
        } else {
            items = itemsWithoutDone
        }
        tableView.reloadData()
    }
    
}

final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

extension ViewController: TodoListHeaderViewDelegate {
    func todoListHeaderView(_ view: TodoListHeaderView, didSelectShowButton isSelected: Bool) {
        showDoneTasks()
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TodoListTableViewCell",
                for: indexPath
            ) as? TodoListTableViewCell
        else {
            return TodoListTableViewCell()
        }
        let newCell = TodoListTableViewCell()
        if indexPath.row == items.count {
            newCell.setLastCell()
            return newCell
        }
        
        newCell.configure(with: items[indexPath.row])
        
        return newCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == items.count {
            let detailsVC = TodoItemDetailsViewController()
            detailsVC.delegate = self
            self.present(detailsVC, animated: true)
        } else {
            let detailsVC = TodoItemDetailsViewController()
            detailsVC.delegate = self
            detailsVC.currentItem = items[indexPath.row]
            self.present(detailsVC, animated: true)
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !items.isEmpty else {
            return nil
        }

        let action = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] (_, _, completionHandler) in
                
                let newItem = self?.items[indexPath.row].copy(done: true)
                self?.fileCache.addChangeTodoItem(newItem!)
                self?.fileCache.loadJsonFromFile("TodoItems")
                
                self?.itemsWithDone = self?.fileCache.todoItems ?? []
                self?.itemsWithoutDone = self?.itemsWithDone.filter { $0.done == false } ?? []
                if let shouldShowDoneTasks = self?.shouldShowDoneTasks {
                    if shouldShowDoneTasks {
                        self?.items = self?.itemsWithDone ?? []
                    } else {
                        self?.items = self?.itemsWithoutDone ?? []
                    }
                }
                
                tableView.reloadData()
                self?.headerView.title = "Выполнено - \((self?.itemsWithDone.count)!-(self?.itemsWithoutDone.count)!)"

                
                completionHandler(true)
            }
        )

        action.image = UIImage(systemName: "checkmark.circle.fill")
        action.backgroundColor = Colors.colorGreen

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !items.isEmpty else {
            return nil
        }

        let openDetailsAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] (_, _, completionHandler) in

            }
        )

        openDetailsAction.image = UIImage(systemName: "info.circle.fill")
        openDetailsAction.backgroundColor = Colors.colorGrayLight

        let deleteAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] (_, _, completionHandler) in
                
                self?.fileCache.removeTodoItem(withID: (self?.items[indexPath.row].id)!)
                self?.fileCache.loadJsonFromFile("TodoItems")
                self?.itemsWithDone = self?.fileCache.todoItems ?? []
                self?.itemsWithoutDone = self?.itemsWithDone.filter { $0.done == false } ?? []
                
                if let shouldShowDoneTasks = self?.shouldShowDoneTasks {
                    if shouldShowDoneTasks {
                        self?.items = self?.itemsWithDone ?? []
                    } else {
                        self?.items = self?.itemsWithoutDone ?? []
                    }
                }
                tableView.reloadData()
                self?.headerView.title = "Выполнено - \((self?.itemsWithDone.count)!-(self?.itemsWithoutDone.count)!)"
                
                completionHandler(true)
            }
        )

        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = Colors.colorRed

        return UISwipeActionsConfiguration(actions: [deleteAction, openDetailsAction])
    }
}


extension ViewController: TodoItemDetailsViewControllerDelegate {
    func didUpdateData() {
        fileCache.loadJsonFromFile("TodoItems")
        itemsWithDone = fileCache.todoItems
        itemsWithoutDone = itemsWithDone.filter { $0.done == false }
        if shouldShowDoneTasks {
            items = itemsWithDone
        } else {
            items = itemsWithoutDone
        }
        tableView.reloadData()
    }
}

