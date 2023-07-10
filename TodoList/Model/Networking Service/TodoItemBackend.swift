//
//  TodoItemBackend.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 06.07.2023.
//

import Foundation
import TodoModelsYandex
import UIKit

struct TodoItemBackend: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int64?
    let isCompleted: Bool
    let color: String?
    let createdAt: Int64
    let changedAt: Int64
    let lastUpdatedBy: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case isCompleted = "done"
        case color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}

extension TodoItemBackend {
    func toTodoItem() -> TodoItem {
        guard let priority = Priority(rawValue: self.importance) else {
            fatalError("Can't parse priority")
        }
        
        let deadline = deadline.map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let createdAt = Date(timeIntervalSince1970: TimeInterval(self.createdAt))
        let changedAt = Date(timeIntervalSince1970: TimeInterval(self.changedAt))
        
        return TodoItem(
            id: self.id,
            text: self.text,
            priority: priority,
            deadline: deadline,
            isCompleted: self.isCompleted,
            createdAt: createdAt,
            changedAt: changedAt)
    }
    
    private func parsePriority(_ priority: String) -> Priority {
        switch priority {
        case "low":
            return .low
        case "basic":
            return .medium
        case "important":
            return .high
        default:
            return .medium
        }
    }
}
