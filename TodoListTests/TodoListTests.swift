//
//  TodoItemTests.swift
//  TodoItemTests
//
//  Created by Daulet Ashikbayev on 13.06.2023.
//

import XCTest
@testable import TodoList

final class TodoListTests: XCTestCase {
    
    func testParse() throws {
        let json: [String: Any] = [
            "id": "1",
            "text": "Test",
            "priority": "low",
            "deadline": 1592052000,
            "completed": true,
            "created_at": 1592052000,
            "changed_at": 1592052000
        ]
        
        let item = TodoItem.parse(json: json)
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.id, "1")
        XCTAssertEqual(item?.text, "Test")
        XCTAssertEqual(item?.priority, .low)
        XCTAssertEqual(item?.deadline, Date(timeIntervalSince1970: 1592052000))
        XCTAssertEqual(item?.isCompleted, true)
        XCTAssertEqual(item?.createdAt, Date(timeIntervalSince1970: 1592052000))
        XCTAssertEqual(item?.changedAt, Date(timeIntervalSince1970: 1592052000))
    }
    
    func testInitializer() {
        let id = "1"
        let text = "Test item"
        let priority = Priority.high
        let deadline = Date()
        let isCompleted = true
        let createdAt = Date()
        let changedAt = Date()
        
        let item1 = TodoItem(id: id, text: text, priority: priority, deadline: deadline, isCompleted: isCompleted, createdAt: createdAt, changedAt: changedAt)
        
        XCTAssertEqual(item1.id, id)
        XCTAssertEqual(item1.text, text)
        XCTAssertEqual(item1.priority, priority)
        XCTAssertEqual(item1.deadline, deadline)
        XCTAssertEqual(item1.isCompleted, isCompleted)
        XCTAssertEqual(item1.createdAt, createdAt)
        XCTAssertEqual(item1.changedAt, changedAt)
        
        let item2 = TodoItem(text: text, priority: priority, deadline: Date(), isCompleted: isCompleted, createdAt: createdAt, changedAt: nil)
        
        XCTAssertNotNil(item2.id)
        XCTAssertEqual(item2.text, text)
        XCTAssertEqual(item2.priority, priority)
        XCTAssertNotNil(item2.deadline)
        XCTAssertEqual(item2.isCompleted, isCompleted)
        XCTAssertEqual(item2.createdAt, createdAt)
        XCTAssertNil(item2.changedAt)
    }
    
    
    func testInvalidJSONParsing() {
        let invalidJSON: [String: Any] = [
            "id": 123,
            "text": "Test",
            "priority": 123,
            "deadline": "2023-06-19",
            "isCompleted": "false",
            "createdAt": 1676454946.0,
            "changedAt": [:]
        ]
        
        let todoItem = TodoItem.parse(json: invalidJSON)
        
        XCTAssertNil(todoItem)
        
        let emptyJSON: [String: Any] = [:]
        
        let emptyItem = TodoItem.parse(json: emptyJSON)
        
        XCTAssertNil(emptyItem)
        
        let missingFieldsJSON: [String: Any] = [
            "text": "Test",
            "isCompleted": true
        ]
        
        let missingFieldsItem = TodoItem.parse(json: missingFieldsJSON)
        
        XCTAssertNil(missingFieldsItem)
        
        let wrongTypeJSON: [String: String] = [
            "id": "1",
            "text": "Test",
            "priority": "low",
            "deadline": "2023-06-19",
            "isCompleted": "true",
            "createdAt": "1676454946",
            "changedAt": "1676454946"
        ]
        
        let wrongTypeItem = TodoItem.parse(json: wrongTypeJSON)
        
        XCTAssertNil(wrongTypeItem)
    }
    
    
    func testTodoItemJSONGeneration() {
        let todoItem = TodoItem(
            id: "789",
            text: "Buy milk",
            priority: .high,
            deadline: Date(timeIntervalSince1970: 1676458546),
            isCompleted: false,
            createdAt: Date(timeIntervalSince1970: 1676454946),
            changedAt: nil
        )
        
        let generatedJSON = todoItem.json
        
        guard let jsonDict = generatedJSON as? [String: Any] else {
            XCTFail("Generated JSON is not a dictionary")
            return
        }
        
        XCTAssertEqual(jsonDict["id"] as? String, "789")
        XCTAssertEqual(jsonDict["text"] as? String, "Buy milk")
        XCTAssertEqual(jsonDict["priority"] as? String, "high")
        XCTAssertEqual(jsonDict["deadline"] as? Int, 1676458546)
        XCTAssertEqual(jsonDict["completed"] as? Bool, Optional(false))
        XCTAssertEqual(jsonDict["created_at"] as? Int, 1676454946)
        XCTAssertNil(jsonDict["changed_at"])
    }
    
    func testCSVGeneration() {
        let item = TodoItem(id: "1", text: "Test", priority: .low, deadline: Date(timeIntervalSince1970: 1676458546), isCompleted: true, createdAt: Date(timeIntervalSince1970: 1676454946), changedAt: Date(timeIntervalSince1970: 1676458546))

        let expectedCSV = """
        id,text,priority,deadline,isCompleted,createdAt,changedAt
        1,Test,low,1676458546,true,1676454946,1676458546\n
        """

        XCTAssertEqual(item.csv, expectedCSV)
    }

    func testCSVParsing() {
        let csv = """
        id,text,priority,deadline,isCompleted,createdAt,changedAt
        1,Test,low,1676458546,true,1676454946,1676458546
        """

        guard let item = TodoItem.parse(csv: csv) else {
            XCTFail("Failed to parse valid CSV")
            return
        }

        XCTAssertEqual(item.id, "1")
        XCTAssertEqual(item.text, "Test")
        XCTAssertEqual(item.priority, .low)
        XCTAssertEqual(item.deadline, Date(timeIntervalSince1970: 1676458546))
        XCTAssertEqual(item.isCompleted, true)
        XCTAssertEqual(item.createdAt, Date(timeIntervalSince1970: 1676454946))
        XCTAssertEqual(item.changedAt, Date(timeIntervalSince1970: 1676458546))
    }

    func testInvalidCSVParsing() {
        // Missing fields in CSV
        let missingFieldsCSV = """
        id,text,createdAt
        1,Test,1676454946
        """

        XCTAssertNil(TodoItem.parse(csv: missingFieldsCSV))

        // Invalid date format in CSV
        let invalidDateFormatCSV = """
        id,text,priority,deadline,isCompleted,createdAt,changedAt
        1,Test,low,2023-02-15 10:55:46,true,invalidDate,1676458546
        """

        XCTAssertNil(TodoItem.parse(csv: invalidDateFormatCSV))

        // Invalid boolean value in CSV
        let invalidBoolValueCSV = """
        id,text,priority,deadline,isCompleted,createdAt,changedAt
        1,Test,low,1676458546,invalidBool,1676454946,1676458546
        """

        XCTAssertNil(TodoItem.parse(csv: invalidBoolValueCSV))
    }

    
}
