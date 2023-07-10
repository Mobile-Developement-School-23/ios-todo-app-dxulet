//
//  NetworkingServiceProvider.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 06.07.2023.
//

import Foundation
import TodoModelsYandex

protocol NetworkingServiceProvider {
    func fetchTodos() async throws -> [TodoItem]
    func syncTodos(_ todoList: [TodoItem]) async throws -> [TodoItem]
    func getTodoItem(id: String) async throws -> TodoItem?
    func addTodoItem(_ todoItem: TodoItem) async throws
    func updateTodoItem(_ todoItem: TodoItem) async throws
    func deleteTodoItem(_ todoItem: TodoItem) async throws -> TodoItem?
}
