import Foundation
import CocoaLumberjackSwift

public class FileCache {
    private(set) public var todoItems: [TodoItem] = []
    
    public static let fileCacheObj = FileCache()
    
    public func set(items: [TodoItem]) {
        todoItems = items
    }
    
    public func addChangeTodoItem(_ item: TodoItem) {
        if let existingItemIndex = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[existingItemIndex] = item
        } else {
            todoItems.append(item)
        }
        saveJsonToFile("TodoItems")
    }
    
    public func removeTodoItem(withID id: String) {
        todoItems.removeAll { $0.id == id }
        saveJsonToFile("TodoItems")
    }
    
    public func saveJsonToFile(_ fileName: String) {
        
        let filePath = Constants.documentDirectory.appendingPathComponent(fileName)

        let jsonArray = todoItems.map { $0.json }
        
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
        else {
            DDLogError("Can't create json from dictionary")
            return
        }
        do {
            try jsonData.write(to: filePath)
            DDLogInfo("Data saved to json file: \(filePath)")
        } catch {
            DDLogError("Failed to save data to json file: \(filePath). Error: \(error)")
            return
        }
    }
    
    public func loadJsonFromFile(_ fileName: String) {

        let filePath = Constants.documentDirectory.appendingPathComponent(fileName)
        
        guard let jsonData = try? Data(contentsOf: filePath)
        else {
            DDLogError("Failed to load data from from json file: \(filePath)")
            return
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [[String : Any]]
        else {
            DDLogError("Can't deserialize data from file: \(filePath)")
            return
        }
        
        
        todoItems = jsonObject.compactMap { TodoItem.parse(json: $0) }
        
        
        DDLogInfo("Data loaded from json file: \(filePath)")
        
    }
    
    
    public func saveCsvToFile(_ fileName: String) {
        
        let filePath = Constants.documentDirectory.appendingPathComponent(fileName)

        let csvString = todoItems.map{ $0.csv }.joined(separator: "\n")
        
        do {
            try csvString.write(to: filePath, atomically: true, encoding: .utf8)
            print("Data saved to csv file: \(filePath)")
        } catch {
            print("Failed to save data to csv file: \(filePath). Error: \(error)")
        }
    }
    
    public func loadCsvFromFile(_ fileName: String) {
        
        let filePath = Constants.documentDirectory.appendingPathComponent(fileName)

        do {
            let csvString = try String(contentsOf: filePath, encoding: .utf8)
            
            let csvLines = csvString.components(separatedBy: "\n")
            
            var loadedItems: [TodoItem] = []
            
            for line in csvLines {
                if let item = TodoItem.parse(csv: line) {
                    loadedItems.append(item)
                }
            }
            
            todoItems = loadedItems
            
            print("Data loaded from csv file: \(filePath)")
        } catch {
            print("Failed to load data from csv file: \(filePath). Error: \(error)")
        }
    }
}



struct Constants {
    static let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!
}
