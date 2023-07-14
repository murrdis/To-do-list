import Foundation
import UIKit
import CoreData
import CocoaLumberjackSwift
import TodoListPackage

final class CoreDataCache: NSObject {
    private(set) public var todoItems: [TodoItem] = []
    
    static let shared = CoreDataCache()
    
    private var context: NSManagedObjectContext { CoreDataContainer.shared.persistentContainer.viewContext }
    
    
//    public func save() {
//        // Удаление существующих записей в CoreData
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TodoEntity")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try context.execute(deleteRequest)
//            // Сохранение каждого элемента в CoreData
//            for item in todoItems {
//                let todoEntity = TodoEntity(context: context)
//                // Настройка свойств сущности
//                todoEntity.id = item.id
//                todoEntity.text = item.text
//                todoEntity.importance = item.importance.rawValue
//                todoEntity.deadline = item.deadline
//                todoEntity.done = item.done
//                todoEntity.created_at = item.created_at
//                todoEntity.changed_at = item.changed_at
//                todoEntity.color = item.color
//            }
//
//            saveContext()
//
//            DDLogInfo("All data saved to CoreData")
//        } catch {
//            DDLogError(error)
//        }
//    }
    
    public func insertTodoItem(_ item: TodoItem) {
        let todoEntity = TodoEntity(context: context)
        todoEntity.id = item.id
        todoEntity.text = item.text
        todoEntity.importance = item.importance.rawValue
        todoEntity.deadline = item.deadline
        todoEntity.done = item.done
        todoEntity.created_at = item.created_at
        todoEntity.changed_at = item.changed_at
        todoEntity.color = item.color
        
        context.insert(todoEntity)
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func updateTodoItem(_ item: TodoItem) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TodoEntity")
        do {
            guard let items = try context.fetch(fetchRequest) as? [TodoEntity],
                  let oldItem = items.first(where: { $0.id == item.id })
            else { return }
            oldItem.id = item.id
            oldItem.text = item.text
            oldItem.importance = item.importance.rawValue
            oldItem.deadline = item.deadline
            oldItem.done = item.done
            oldItem.created_at = item.created_at
            oldItem.changed_at = item.changed_at
            oldItem.color = item.color

            try context.save()
        } catch {
            print(error)
        }
    }
    
    func removeTodoItem(withID id: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TodoEntity")
        do {
            guard let items = try context.fetch(fetchRequest) as? [TodoEntity],
                  var item = items.first(where: { $0.id == id })
            else { return }
            context.delete(item)

            try context.save()
        } catch {
            print(error)
        }
    }
    
    public func loadFromCoreData() {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest() as! NSFetchRequest<TodoEntity>
        
        do {
            let fetchedItems = try context.fetch(fetchRequest)
            
            todoItems = fetchedItems.compactMap { todoEntity in
                return TodoItem(
                    id: todoEntity.id!,
                    text: todoEntity.text!,
                    importance: TodoItem.Importance(rawValue: todoEntity.importance!) ?? .basic,
                    deadline: todoEntity.deadline,
                    done: todoEntity.done,
                    created_at: todoEntity.created_at!,
                    changed_at: todoEntity.changed_at,
                    color: todoEntity.color
                )
            }
            
            DDLogInfo("Data loaded from CoreData")
        } catch {
            DDLogError("Failed to load data from CoreData. Error: \(error)")
        }
    }
    
}
