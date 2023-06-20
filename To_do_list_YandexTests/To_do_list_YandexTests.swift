import XCTest
@testable import To_do_list_Yandex

class TodoItemTests: XCTestCase {
    
    func testInit() {
        let testText = "SALAM"
        let item1 = TodoItem(text: testText)
        
        XCTAssertNotNil(UUID(uuidString: item1.id))
        XCTAssertEqual(item1.createdAt.timeIntervalSince1970, Date.now.timeIntervalSince1970, accuracy: TimeInterval(1))
        XCTAssertEqual(item1.text, testText)
        XCTAssertEqual(item1.importance, .normal)
        XCTAssertEqual(item1.deadline, nil)
        XCTAssertEqual(item1.changedAt, nil)
        XCTAssertEqual(item1.done, false)
        
        let currentDate = Date()
        let item2 = TodoItem(id: "2", text: "Bye", importance: .important, deadline: currentDate, done: true, createdAt: currentDate, changedAt: currentDate)
        
        XCTAssertEqual(item2.id, "2")
        XCTAssertEqual(item2.createdAt, currentDate)
        XCTAssertEqual(item2.text, "Bye")
        XCTAssertEqual(item2.importance, .important)
        XCTAssertEqual(item2.deadline, currentDate)
        XCTAssertEqual(item2.changedAt, currentDate)
        XCTAssertEqual(item2.done, true)
    }
    
    func testJSONParsing() {
        let json: [String: Any] = [
            "id": "1",
            "text": "Buy groceries",
            "importance": "важная",
            "deadline": 1623744000.0,
            "done": true,
            "createdAt": 1623590400.0,
            "changedAt": 1623662400.0
        ]
        
        let item = TodoItem.parse(json: json)
        
        XCTAssertEqual(item?.id, "1")
        XCTAssertEqual(item?.text, "Buy groceries")
        XCTAssertEqual(item?.importance, .important)
        XCTAssertEqual(item?.deadline, Date(timeIntervalSince1970: 1623744000.0))
        XCTAssertTrue(item?.done ?? false)
        XCTAssertEqual(item?.createdAt, Date(timeIntervalSince1970: 1623590400.0))
        XCTAssertEqual(item?.changedAt, Date(timeIntervalSince1970: 1623662400.0))
    }
    
    func testInvalidJSONParsing() {
        let json: [String: Any] = [
            "id": "1",
            "text": "Buy groceries",
            "importance": "invalid",
            "done": true,
            "createdAt": "323"
        ]
        
        let item = TodoItem.parse(json: json)
        
        XCTAssertNil(item)
        
        let json2: [String: Any] = [
            "id": "123",
            // Missing "text" field
            "importance": "важная",
            "deadline": 1654302000,
            "done": true,
            "createdAt": 1654094400
        ]
        
        let item2 = TodoItem.parse(json: json2)
        
        XCTAssertNil(item2)
    }
    
    func testJSON() {
        let todoItem = TodoItem(
            id: "123",
            text: "Buy groceries",
            importance: .important,
            deadline: Date(timeIntervalSince1970: 1654302000),
            done: true,
            createdAt: Date(timeIntervalSince1970: 1654094400),
            changedAt: Date(timeIntervalSince1970: 1654180800) // 02/01/2022 12:00:00 AM
        )
        
        let json = todoItem.json as? [String: Any]
        
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["id"] as? String, "123")
        XCTAssertEqual(json?["text"] as? String, "Buy groceries")
        XCTAssertEqual(json?["importance"] as? String, "важная")
        XCTAssertEqual(json?["deadline"] as? TimeInterval, 1654302000)
        XCTAssertTrue(json?["done"] as? Bool ?? false)
        XCTAssertEqual(json?["createdAt"] as? TimeInterval, 1654094400)
        XCTAssertEqual(json?["changedAt"] as? TimeInterval, 1654180800)
    }
    
    func testCSVParsing() {
        let csv = "1,Buy groceries,важная,1623744000.0,true,1623590400.0,1623662400.0"
        
        let item = TodoItem.parse(csv: csv)
        
        XCTAssertEqual(item?.id, "1")
        XCTAssertEqual(item?.text, "Buy groceries")
        XCTAssertEqual(item?.importance, .important)
        XCTAssertEqual(item?.deadline, Date(timeIntervalSince1970: 1623744000.0))
        XCTAssertTrue(item?.done ?? false)
        XCTAssertEqual(item?.createdAt, Date(timeIntervalSince1970: 1623590400.0))
        XCTAssertEqual(item?.changedAt, Date(timeIntervalSince1970: 1623662400.0))
    }
    
    func testInvalidCSVParsing() {
        let csv = "1,,invalid,%,true,privet,1623744000.0"
        
        let item = TodoItem.parse(csv: csv)
        
        XCTAssertNil(item)
    }
    
    func testJSONSerialization() {
        let item = TodoItem(
            id: "1",
            text: "Buy groceries",
            importance: .important,
            deadline: Date(timeIntervalSince1970: 1623744000.0),
            done: true,
            createdAt: Date(timeIntervalSince1970: 1623590400.0),
            changedAt: Date(timeIntervalSince1970: 1623662400.0)
        )
        
        let json = item.json as? [String: Any]
        
        XCTAssertEqual(json?["id"] as? String, "1")
        XCTAssertEqual(json?["text"] as? String, "Buy groceries")
        XCTAssertEqual(json?["importance"] as? String, "важная")
        XCTAssertEqual(json?["deadline"] as? TimeInterval, 1623744000.0)
        XCTAssertTrue(json?["done"] as? Bool ?? false)
        XCTAssertEqual(json?["createdAt"] as? TimeInterval, 1623590400.0)
        XCTAssertEqual(json?["changedAt"] as? TimeInterval, 1623662400.0)
    }
    
    func testCSVSerialization() {
        let item = TodoItem(
            id: "1",
            text: "Buy groceries",
            importance: .important,
            deadline: Date(timeIntervalSince1970: 1623744000.0),
            done: true,
            createdAt: Date(timeIntervalSince1970: 1623590400.0),
            changedAt: Date(timeIntervalSince1970: 1623662400.0)
        )
        
        let csv = item.csv
        
        XCTAssertEqual(csv, "1,Buy groceries,важная,1623744000.0,true,1623590400.0,1623662400.0")
    }
    
    func testCSV() {
        let todoItem = TodoItem(
            id: "123",
            text: "Buy groceries",
            importance: .important,
            deadline: Date(timeIntervalSince1970: 1654302000),
            done: true,
            createdAt: Date(timeIntervalSince1970: 1654094400),
            changedAt: Date(timeIntervalSince1970: 1654180800)
        )
        
        let csv = todoItem.csv
        
        XCTAssertEqual(csv, "123,Buy groceries,важная,1654302000.0,true,1654094400.0,1654180800.0")
    }
}
