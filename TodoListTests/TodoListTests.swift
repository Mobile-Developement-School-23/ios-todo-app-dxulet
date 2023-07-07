//
//  TodoItemTests.swift
//  TodoItemTests
//
//  Created by Daulet Ashikbayev on 13.06.2023.
//

import XCTest
import TodoModelsYandex
@testable import TodoList

final class TodoListTests: XCTestCase {
    private let session = URLSession.shared
    private let fileContents = "Hello, world!"
    private var fileURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let fileName = "TodoListTests-" + UUID().uuidString
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
        try Data(fileContents.utf8).write(to: fileURL)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testDataFromURLWithoutError() async throws {
        let (data, response) = try await session.data(from: fileURL)
        let string = String(decoding: data, as: UTF8.self)

        XCTAssertEqual(string, fileContents)
        XCTAssertEqual(response.url, fileURL)
    }

    func testDataFromURLThatThrowsError() async {
        let invalidURL = fileURL.appendingPathComponent("doesNotExist")

        do {
            _ = try await session.data(from: invalidURL)
            XCTFail("Expected error to be thrown")
        } catch {
            verifyThatError(error, containsURL: invalidURL)
        }
    }

    func testDataWithURLRequestWithoutError() async throws {
        let request = URLRequest(url: fileURL)
        let (data, response) = try await session.dataTask(for: request)
        let string = String(decoding: data, as: UTF8.self)

        XCTAssertEqual(string, fileContents)
        XCTAssertEqual(response.url, fileURL)
    }

    func testDataWithURLRequestThatThrowsError() async {
        let invalidURL = fileURL.appendingPathComponent("doesNotExist")
        let request = URLRequest(url: invalidURL)

        do {
            _ = try await session.dataTask(for: request)
            XCTFail("Expected error to be thrown")
        } catch {
            verifyThatError(error, containsURL: invalidURL)
        }
    }

    func testCancellingParentTaskCancelsDataTask() async throws {
        let task = Task {
            do {
                let (data, _) = try await session.data(from: fileURL)
                if Task.isCancelled { return 0 }
                
                return data.count
            } catch {
                if Task.isCancelled { return 0 }
                
                throw error
            }
        }
        
        task.cancel()
        let result = try await task.value
        
        XCTAssertEqual(result, 0)
    }
    
    // MARK: - Network Service
    
    func testFetchTodos() async throws {
        let service = NetworkingService(session: session, deviceID: "test")
        let todos = try await service.fetchTodos()
        
        XCTAssertFalse(todos.isEmpty)
    }
    
    func testAddTodoItem() async throws {
        let service = NetworkingService(session: session, deviceID: "test")
        let todoItem = TodoItem(
            id: UUID().uuidString,
            text: "Test",
            priority: .low,
            deadline: nil,
            isCompleted: false,
            createdAt: Date(),
            changedAt: Date())
        
        let todos = try await service.fetchTodos().count
        try await service.addTodoItem(todoItem)
        let newTodos = try await service.fetchTodos().count
        
        XCTAssertFalse(todos >= newTodos)
    }
    
}

private extension TodoListTests {
    func verifyThatError(_ error: Error, containsURL url: URL) {
        XCTAssertTrue("\(error)".contains(url.absoluteString))
    }
}
