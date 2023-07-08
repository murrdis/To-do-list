import Foundation
import UIKit

public struct TodoItem {
    public let id: String
    public let text: String
    public let importance: Importance
    public let deadline: Date?
    public let done: Bool
    public let created_at: Date
    public let changed_at: Date?
    public let color: HEX?
    public let last_updated_by: String
    
    public enum Importance: String {
        case low
        case basic
        case important
    }
    
    public init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .basic,
         deadline: Date? = nil,
         done: Bool = false,
         created_at: Date = Date(),
         changed_at: Date? = nil,
         color: HEX? = nil) {
            self.id = id
            self.text = text
            self.importance = importance
            self.deadline = deadline
            self.done = done
            self.created_at = created_at
            self.changed_at = changed_at
            self.color = color
            self.last_updated_by = UIDevice.current.identifierForVendor?.uuidString ?? ""
        }
}

extension TodoItem {
    public static func parse(json: Any) -> TodoItem? {
        
        guard let dict = json as? [String: Any],
              let text = dict["text"] as? String,
              let done = dict["done"] as? Bool,
              let createdAtTimestamp = dict["created_at"] as? TimeInterval
        else {
            return nil
        }
        
        let id = dict["id"] as? String ?? UUID().uuidString
        
        let importanceString = dict["importance"] as? String
        let importance = Importance(rawValue: importanceString ?? Importance.basic.rawValue) ?? .basic
        
        let deadlineTimestamp = dict["deadline"] as? TimeInterval
        let deadline = deadlineTimestamp != nil ? Date(timeIntervalSince1970: deadlineTimestamp!) : nil
        
        let created_at = Date(timeIntervalSince1970: createdAtTimestamp)
        
        let changedAtTimestamp = dict["changed_at"] as? TimeInterval
        let changed_at = changedAtTimestamp != nil ? Date(timeIntervalSince1970: changedAtTimestamp!) : nil
        
        let color = dict["color"] as? HEX
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: done,
            created_at: created_at,
            changed_at: changed_at,
            color: color
        )
    }
    
    public var json: Any {
        var dict: [String: Any] = [
            "id": id,
            "text": text,
            "done": done,
            "created_at": created_at.timeIntervalSince1970
        ]
        
        if importance != .basic {
            dict["importance"] = importance.rawValue
        }
        
        if let theDeadline = deadline {
            dict["deadline"] = theDeadline.timeIntervalSince1970
        }
        
        if let theModificationDate = changed_at {
            dict["changed_at"] = theModificationDate.timeIntervalSince1970
        }
        
        if let color = color {
            dict["color"] = color
        }
        
        return dict

    }
}

extension TodoItem {
    public static func parse(csv: String) -> TodoItem? {
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
        
        let importance: Importance = components[components.count-5].isEmpty ? .basic : Importance(rawValue: components[components.count-5]) ?? .basic
        
        var text = components[1]
        
        for comp in 1..<components.count-5 {
            text.append(components[comp])
            if comp != components.count-6 {
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
            created_at: createdAt!,
            changed_at: changedAt)
    }
    
    public var csv: String {
        var csvString = "\(id),\(text),"
        
        if importance != .basic {
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
        
        csvString += "\(done),\(created_at.timeIntervalSince1970),"
        
        if let theModificationDate = changed_at {
            let modificationTimestamp = theModificationDate.timeIntervalSince1970
            csvString += "\(modificationTimestamp)"
        }
        
        return csvString
    }
}


extension TodoItem {
    public func copy(
        text: String? = nil,
        importance: Importance? = nil,
        deadline: Date? = nil,
        done: Bool? = nil,
        createdAt: Date? = nil,
        changedAt: Date? = nil,
        color: HEX? = nil
    ) -> TodoItem {
        return TodoItem(
            id: id,
            text: text ?? self.text,
            importance: importance ?? self.importance,
            deadline: deadline ?? self.deadline,
            done: done ?? self.done,
            created_at: createdAt ?? self.created_at,
            changed_at: changedAt ?? self.changed_at,
            color: color ?? self.color
        )
    }
}
