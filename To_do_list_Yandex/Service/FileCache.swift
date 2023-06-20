import Foundation

class FileCache {
    private(set) var todoItems: [TodoItem] = []
    
    func addTodoItem(_ item: TodoItem) {
        if let existingItemIndex = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[existingItemIndex] = item
        } else {
            todoItems.append(item)
        }
    }
    
    func removeTodoItem(withID id: String) {
        todoItems.removeAll { $0.id == id }
    }
    
    func saveJsonToFile(_ fileName: String) {
        
        let filePath = Constants.documentDirectory.appendingPathComponent(fileName)
        
        
        
        do {
            let jsonArray = todoItems.map { $0.json }
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)

            try jsonData.write(to: filePath)
            print("Data saved to json file: \(filePath)")
        } catch {
            // Нужно кидать ошибки
            print("Failed to save data to json file: \(filePath). Error: \(error)")
        }
    }
    
    func loadJsonFromFile(_ fileName: String) {

        let filePath = Constants.documentDirectory.appendingPathComponent(fileName)
        
        do {
            let jsonData = try Data(contentsOf: filePath)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [[String : Any]]
            
            if let jsonArray = jsonObject {
                todoItems = jsonArray.compactMap { TodoItem.parse(json: $0) }
            }
            
            print("Data loaded from json file: \(filePath)")
        } catch {
            print("Failed to load data from json file: \(filePath). Error: \(error)")
        }
    }
    
    
    func saveCsvToFile(_ fileName: String) {
        
        let filePath = Constants.documentDirectory.appendingPathComponent(fileName)

        let csvString = todoItems.map{ $0.csv }.joined(separator: "\n")
        
        do {
            try csvString.write(to: filePath, atomically: true, encoding: .utf8)
            print("Data saved to csv file: \(filePath)")
        } catch {
            print("Failed to save data to csv file: \(filePath). Error: \(error)")
        }
    }
    
    func loadCsvFromFile(_ fileName: String) {
        
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
