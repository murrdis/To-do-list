import Foundation
import TodoListPackage
import CocoaLumberjackSwift
import SQLite

class DatabaseCache {
    private(set) public var todoItems: [TodoItem] = []
    
    static let shared = DatabaseCache()
    
    private var db: Connection
    private let table = Table("todoItems")
    
    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let importance = Expression<String>("importance")
    private let deadline = Expression<Date?>("deadline")
    private let done = Expression<Bool>("done")
    private let created_at = Expression<Date>("created_at")
    private let changed_at = Expression<Date?>("changed_at")
    private let color = Expression<String?>("color")
    //private let last_updated_by = Expression<String>("last_updated_by")
    
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbPath = "\(path)/todoItems.sqlite"
        
        do {
            db = try Connection(dbPath)
            createTableIfNeeded()
        } catch {
            fatalError("Failed to open database: \(error)")
        }
    }
    
    private func createTableIfNeeded() {
        do {
            try db.run(table.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(text)
                table.column(importance)
                table.column(deadline)
                table.column(done)
                table.column(created_at)
                table.column(changed_at)
                table.column(color)
                //table.column(last_updated_by)
            })
        } catch {
            fatalError("Failed to create table: \(error)")
        }
    }
    
    func insertTodoItem(_ item: TodoItem) {
        do {
            try db.run(table.insert(
                id <- item.id,
                text <- item.text,
                importance <- item.importance.rawValue,
                deadline <- item.deadline,
                done <- item.done,
                created_at <- item.created_at,
                created_at <- item.created_at,
                changed_at <- item.changed_at,
                color <- item.color
            ))
            DDLogInfo("Todo item inserted into database: \(item.id)")
        } catch {
            DDLogError("Failed to insert todo item into database: \(error)")
        }
    }
    
    func updateTodoItem(_ item: TodoItem) {
        let itemToUpdate = table.filter(id == item.id)
        do {
            try db.run(itemToUpdate.update(
                text <- item.text,
                importance <- item.importance.rawValue,
                deadline <- item.deadline,
                done <- item.done,
                created_at <- item.created_at,
                changed_at <- item.changed_at,
                color <- item.color
            ))
            DDLogInfo("Todo item updated in database: \(item.id)")
        } catch {
            DDLogError("Failed to update todo item in database: \(error)")
        }
    }
    
    func removeTodoItem(withID id: String) {
        let itemToDelete = table.filter(self.id == id)
        do {
            try db.run(itemToDelete.delete())
            DDLogInfo("Todo item removed from database: \(id)")
        } catch {
            DDLogError("Failed to remove todo item from database: \(error)")
        }
    }
    
    
    func loadFromDatabase() {
        do {
            let items = try db.prepare(table)
            todoItems = items.compactMap { row in
                return TodoItem(
                    id: row[id],
                    text: row[text],
                    importance: TodoItem.Importance(rawValue: row[importance]) ?? .basic,
                    deadline: row[deadline],
                    done: row[done],
                    created_at: row[created_at],
                    changed_at: row[changed_at],
                    color: row[color]
                )
            }
            DDLogInfo("Data loaded from database")
        } catch {
            DDLogError("Failed to load data from database: \(error)")
        }
    }
    
}
