import Foundation

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let done: Bool
    let createdAt: Date
    let changedAt: Date?
    
    enum Importance: String {
        case notImportant = "неважная"
        case normal = "обычная"
        case important = "важная"
    }
    
    init(id: String = UUID().uuidString, text: String, importance: Importance = .normal, deadline: Date? = nil, done: Bool = false, createdAt: Date = Date.now, changedAt: Date? = nil) {
            self.id = id
            self.text = text
            self.importance = importance
            self.deadline = deadline
            self.done = done
            self.createdAt = createdAt
            self.changedAt = changedAt
        }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        
        guard let dict = json as? [String: Any],
              let text = dict["text"] as? String,
              let done = dict["done"] as? Bool,
              let createdAtTimestamp = dict["createdAt"] as? TimeInterval
        else {
            return nil
        }
        
        let id = dict["id"] as? String ?? UUID().uuidString
        
        let importanceString = dict["importance"] as? String
        let importance = Importance(rawValue: importanceString ?? "обычная") ?? .normal
        
        let deadlineTimestamp = dict["deadline"] as? TimeInterval
        let deadline = deadlineTimestamp != nil ? Date(timeIntervalSince1970: deadlineTimestamp!) : nil
        
        let createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
        
        let changedAtTimestamp = dict["changedAt"] as? TimeInterval
        let changedAt = changedAtTimestamp != nil ? Date(timeIntervalSince1970: changedAtTimestamp!) : nil
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: done,
            createdAt: createdAt,
            changedAt: changedAt)
    }
    
    var json: Any {
        var dict: [String: Any] = [
            "id": id,
            "text": text,
            "done": done,
            "createdAt": createdAt.timeIntervalSince1970
        ]
        
        if importance != .normal {
            dict["importance"] = importance.rawValue
        }
        
        if let theDeadline = deadline {
            dict["deadline"] = theDeadline.timeIntervalSince1970
        }
        
        if let theModificationDate = changedAt {
            dict["changedAt"] = theModificationDate.timeIntervalSince1970
        }
        return dict

    }
}

extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let components = csv.components(separatedBy: ",")
        
        guard components.count >= 7 else {
            return nil
        }
        
        let id = components[0].isEmpty ? UUID().uuidString : components[0]
        
        var deadline: Date? = nil
        var createdAt: Date? = nil
        var changedAt: Date? = nil
        
        if !components[components.count-1].isEmpty {
            let timeInterval = TimeInterval(components[components.count-1])
            changedAt = (timeInterval != nil) ? Date(timeIntervalSince1970: timeInterval!) : nil
        }
        
        if !components[components.count-2].isEmpty {
            let timeInterval = TimeInterval(components[components.count-2])
            createdAt = (timeInterval != nil) ? Date(timeIntervalSince1970: timeInterval!) : nil
        }
        
        let isCompleted = components[components.count-3].lowercased() == "true"
        
        if !components[components.count-4].isEmpty {
            let timeInterval = TimeInterval(components[components.count-4])
            deadline = (timeInterval != nil) ? Date(timeIntervalSince1970: timeInterval!) : nil
        }
        
        let importance: Importance = components[components.count-5].isEmpty ? .normal : Importance(rawValue: components[components.count-5]) ?? .normal
        
        var text = components[1]
        
        for i in 1..<components.count-5 {
            text.append(components[i])
            if i != components.count-6 {
                text.append(",")
            }
        }
        
        if text.isEmpty || createdAt == nil {
            return nil
        }
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: isCompleted,
            createdAt: createdAt!,
            changedAt: changedAt)
    }
    
    var csv: String {
        var csvString = "\(id),\(text),"
        
        if importance != .normal {
            csvString += "\(importance.rawValue),"
        } else {
            csvString += ","
        }
        
        if let theDeadline = deadline {
            let deadlineTimestamp = theDeadline.timeIntervalSince1970
            csvString += "\(deadlineTimestamp),"
        } else {
            csvString += ","
        }
        
        csvString += "\(done),\(createdAt.timeIntervalSince1970),"
        
        if let theModificationDate = changedAt {
            let modificationTimestamp = theModificationDate.timeIntervalSince1970
            csvString += "\(modificationTimestamp)"
        }
        
        return csvString
    }
}