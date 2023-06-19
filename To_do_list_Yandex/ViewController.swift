import UIKit
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        let fileCache = FileCache()
        let item1 = TodoItem(id: "1",
                             text: "a",
                             importance: .important,
                             deadline: Date(),
                             done: true,
                             createdAt: Date(),
                             changedAt: nil)
        let item2 = TodoItem(id: "2",
                             text: "b,c",
                             importance: .normal,
                             deadline: Date(),
                             done: true,
                             createdAt: Date(),
                             changedAt: nil)
        fileCache.addTodoItem(item1)
        fileCache.addTodoItem(item2)
        print(fileCache.todoItems.count)
        fileCache.saveCsvToFile("items.txt")
        fileCache.loadCsvFromFile("items.txt")
        print(fileCache.todoItems.count)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

