import UIKit
import Foundation

class ViewController: UIViewController {
    
    let fileCache = FileCache.fileCacheObj
//    private var items: [TodoItem] = [] {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
    private var items = [
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Read a book", deadline: Date()),
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Buy groceries", importance: .normal, done: true),
        TodoItem(text: "Buy groceries", importance: .important, hexColor: UIColor(red: 0, green: 250, blue: 0, alpha: 1.0).hex),
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Buy groceries", importance: .important),
    ]
    
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

    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
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
        view.addSubview(tableView)
        view.addSubview(addButton)
//        scrollView.addSubview(mainStackView)
//        scrollView.addSubview(addButton)
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
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
        NSLayoutConstraint.activate(
            [
                addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
                
            ]
        )
        
        //        NSLayoutConstraint.activate(
        //            [
//                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//                scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            ]
//        )
//
//        NSLayoutConstraint.activate([
//            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor,
//                                                  constant: 16),
//            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            mainStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
//                                                    constant: -16),
//            mainStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
//                                                   constant: 16),
//            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
//        ])
//

    }
    
    @objc
    private func didTapAddButton(_ sender: UIButton) {
        
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
        
        if indexPath.row == items.count {
            cell.setLastCell()
            return cell
        }
        
        cell.configure(with: items[indexPath.row])
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
}

//extension ViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        guard !items.isEmpty else {
//            return nil
//        }
//
//        let action = UIContextualAction(
//            style: .normal,
//            title: nil,
//            handler: { [weak self] (_, _, completionHandler) in
//
//            }
//        )
//
//        action.image = UIImage(systemName: "checkmark.circle.fill")
//        action.backgroundColor = DSColor.colorGreen.color
//
//        return UISwipeActionsConfiguration(actions: [action])
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        guard !items.isEmpty else {
//            return nil
//        }
//
//        let openDetailsAction = UIContextualAction(
//            style: .normal,
//            title: nil,
//            handler: { [weak self] (_, _, completionHandler) in
//
//            }
//        )
//
//        openDetailsAction.image = UIImage(systemName: "info.circle.fill")
//        openDetailsAction.backgroundColor = DSColor.colorGrayLight.color
//
//        let deleteAction = UIContextualAction(
//            style: .normal,
//            title: nil,
//            handler: { [weak self] (_, _, completionHandler) in
//
//            }
//        )
//
//        deleteAction.image = UIImage(systemName: "trash.fill")
//        deleteAction.backgroundColor = DSColor.colorRed.color
//
//        return UISwipeActionsConfiguration(actions: [deleteAction, openDetailsAction])
//    }
//}
