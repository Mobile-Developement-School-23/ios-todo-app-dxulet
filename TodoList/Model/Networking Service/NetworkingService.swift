//
//  NetworkingService.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 06.07.2023.
//

import Foundation
import TodoModelsYandex
import UIKit

class NetworkingService: NetworkingServiceProvider {
    
    private let session: URLSession
    private(set) var revision: Int32 = 0
    private let deviceID: String
    
    init(session: URLSession = .shared, deviceID: String) {
        self.session = session
        self.deviceID = deviceID
    }
    
    func fetchTodos() async throws -> [TodoItem] {
        let url = try RequestProcessor.makeURL()
        let request = try RequestProcessor.makeRequest(method: "GET", url: url, revision: revision)
        let (data, _) = try await RequestProcessor.performRequest(request)
        let list = try decodeListBackend(from: data)
        return list
    }
    
    func syncTodos(_ todoList: [TodoItem]) async throws -> [TodoItem] {
        let list = ListBackend(list: todoList.map { toTodoItemBackend($0) })
        let body = try JSONEncoder().encode(list)
        let url = try RequestProcessor.makeURL()
        let request = try RequestProcessor.makeRequest(method: "PATCH", url: url, body: body, revision: revision)
        let (data, _) = try await RequestProcessor.performRequest(request)
        let item = try decodeListBackend(from: data)
        return item
    }
    
    func getTodoItem(id: String) async throws -> TodoItem? {
        let url = try RequestProcessor.makeURL(id: id)
        let request = try RequestProcessor.makeRequest(method: "GET", url: url, revision: revision)
        let (data, _) = try await RequestProcessor.performRequest(request)
        let item = try decodeListBackend(from: data).first
        return item
    }
    
    func addTodoItem(_ todoItem: TodoItem) async throws {
        let item = ElementBackend(element: toTodoItemBackend(todoItem))
        let body = try JSONEncoder().encode(item)
        let url = try RequestProcessor.makeURL()
        let request = try RequestProcessor.makeRequest(method: "POST", url: url, body: body, revision: revision)
        try await RequestProcessor.performRequest(request)
    }
    
    func updateTodoItem(_ todoItem: TodoItem) async throws {
        let item = ElementBackend(element: toTodoItemBackend(todoItem))
        let body = try JSONEncoder().encode(item)
        let url = try RequestProcessor.makeURL(id: "/\(todoItem.id)")
        let request = try RequestProcessor.makeRequest(method: "PUT", url: url, body: body, revision: revision)
        try await RequestProcessor.performRequest(request)
    }
    
    @discardableResult
    func deleteTodoItem(_ todoItem: TodoItem) async throws -> TodoItem? {
        let url = try RequestProcessor.makeURL(id: "/\(todoItem.id)")
        let request = try RequestProcessor.makeRequest(method: "DELETE", url: url, revision: revision)
        let (data, _) = try await RequestProcessor.performRequest(request)
        let item = try decodeListBackend(from: data).first
        return item
    }
    
    // MARK: - Helpers
    private func toTodoItemBackend(_ todoItem: TodoModelsYandex.TodoItem) -> TodoItemBackend {
        return TodoItemBackend(
            id: todoItem.id,
            text: todoItem.text,
            importance: todoItem.priority.rawValue,
            deadline: todoItem.deadline.map { Int64($0.timeIntervalSince1970) },
            isCompleted: todoItem.isCompleted,
            color: "#FFFFFF",
            createdAt: Int64(todoItem.createdAt.timeIntervalSince1970),
            changedAt: Int64((todoItem.changedAt ?? todoItem.createdAt).timeIntervalSince1970),
            lastUpdatedBy: deviceID)
    }
    
    private func decodeListBackend(from data: Data) throws -> [TodoItem] {
        let decoder = JSONDecoder()
        
        let listBackend = try decoder.decode(ListBackend.self, from: data)
        if let revision = listBackend.revision {
            self.revision = revision
        }
        return listBackend.list.map { $0.toTodoItem() }
    }
}

enum RequestProcessorError: Error {
    case invalidURL(URLComponents)
    case invalidResponse
    case invalidData
}

enum RequestProcessor {
    
    private enum Constants {
        static let scheme = "https"
        static let baseURL = "beta.mrdekk.ru"
        static let path = "/todobackend/list"
        static let bearer = "Bearer "
        static let token = "dovetailing"
    }
    
    static func makeRequest(method: String, url: URL, body: Data? = nil, revision: Int32) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(Constants.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        return request
    }
    
    static func performRequest(session: URLSession = .shared, _ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw RequestProcessorError.invalidResponse
        }
        try handleStatusCode(response.statusCode)
        return (data, response)
    }
    
    static func makeURL(id: String = "") throws -> URL {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.baseURL
        components.path = Constants.path + id
        
        guard let url = components.url else {
            throw RequestProcessorError.invalidURL(components)
        }
        return url
    }
    
    static func handleStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case 200...299:
            break
        case 400...499:
            throw RequestProcessorError.invalidResponse
        case 500...599:
            throw RequestProcessorError.invalidResponse
        default:
            throw RequestProcessorError.invalidResponse
        }
    }
}
