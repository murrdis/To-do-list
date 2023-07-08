import Foundation
import CocoaLumberjackSwift
import TodoListPackage

enum NetworkErrors: Error {
    case couldNotCreateUrl
    case couldNotDecode
}

protocol NetworkingService {
    func getList() async throws -> [TodoItem]
    func patchList(_ todoItems: [TodoItem]) async throws -> [TodoItem]
    func getTask(with id: String) async throws -> TodoItem
    func postTask(_ todoItem: TodoItem) async throws -> TodoItem
    func putTask(_ todoItem: TodoItem) async throws -> TodoItem
    func deleteTask(with id: String) async throws -> TodoItem
}

class DefaultNetworkingService: NetworkingService {

    private let token = "trilobated2"
    private var revision: Int = 0

    private func makeURL(with id: String = "") -> URL? {
        let end = id.isEmpty ? "/list" : "/list/\(id)"
        return URL(string: "https://beta.mrdekk.ru/todobackend" + end)
    }
    
    func getList() async throws -> [TodoItem] {
        guard let url = makeURL()
        else { throw NetworkErrors.couldNotCreateUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        
        let todoItems = try parseTodoItems(data: data)
        DDLogInfo("GET list completed successfully")
        return todoItems
    }
    
    func patchList(_ todoItems: [TodoItem]) async throws -> [TodoItem] {
        guard let url = makeURL()
        else { throw NetworkErrors.couldNotCreateUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        request.httpBody = try JSONSerialization.data(withJSONObject: ["list": todoItems.map({ $0.json })])
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let todoItems = try parseTodoItems(data: data)
        DDLogInfo("PATCH list completed successfully")
        return todoItems
    }

    func getTask(with id: String) async throws -> TodoItem {
        
        guard let url = makeURL(with: id)
        else { throw NetworkErrors.couldNotCreateUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        
        let todoItem = try parseTodoItem(data: data)
        DDLogInfo("GET element completed successfully")
        return todoItem
    }
    
    
    func postTask(_ todoItem: TodoItem) async throws -> TodoItem {
        
        guard let url = makeURL()
        else { throw NetworkErrors.couldNotCreateUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        request.httpBody = try JSONSerialization.data(withJSONObject: ["element": todoItem.json])
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let todoItem = try parseTodoItem(data: data)
        DDLogInfo("POST element completed successfully")
        return todoItem
    }



    func putTask(_ todoItem: TodoItem) async throws -> TodoItem {

        guard let url = makeURL(with: todoItem.id)
        else { throw NetworkErrors.couldNotCreateUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        request.httpBody = try JSONSerialization.data(withJSONObject: ["element": todoItem.json])
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        
        let todoItem = try parseTodoItem(data: data)
        DDLogInfo("PUT element completed successfully")
        return todoItem
    }



    func deleteTask(with id: String) async throws -> TodoItem {
        
        guard let url = makeURL(with: id)
        else { throw NetworkErrors.couldNotCreateUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        
        let todoItem = try parseTodoItem(data: data)
        DDLogInfo("DELETE element completed successfully")
        return todoItem
    }


    func parseTodoItems(data: Data) throws -> [TodoItem] {
        guard
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let revision = jsonArray["revision"] as? Int,
            let list = jsonArray["list"] as? [[String: Any]]
        else { throw NetworkErrors.couldNotDecode }
        var todoItems: [TodoItem] = []
        for task in list {
            guard let todoItem = TodoItem.parse(json: task)
            else { throw NetworkErrors.couldNotDecode }
            todoItems.append(todoItem)
        }
        self.revision = revision
        DDLogInfo("revision = \(self.revision)")
        return todoItems
    }

    func parseTodoItem(data: Data) throws -> TodoItem {
        guard
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let revision = jsonArray["revision"] as? Int,
            let element = jsonArray["element"] as? [String: Any],
            let todoItem = TodoItem.parse(json: element)
        else { throw URLError(.cannotDecodeContentData) }
        self.revision = revision
        DDLogInfo("revision = \(self.revision)")
        return todoItem
    }
}
