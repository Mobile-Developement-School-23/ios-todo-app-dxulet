//
//  TodoItem.swift
//  TodoItem
//
//  Created by Daulet Ashikbayev on 13.06.2023.
//

import Foundation

enum Priority: String {
    case low
    case medium
    case high
}

enum JsonKeys {
    static let taskId = "id"
    static let taskText = "text"
    static let taskPriority = "priority"
    static let taskDeadline = "deadline"
    static let taskIsCompleted = "completed"
    static let taskCreatedAt = "created_at"
    static let taskChangedAt = "changed_at"
}


struct TodoItem {
    let id: String
    let text: String
    let priority: Priority
    let deadline: Date?
    var isCompleted: Bool
    let createdAt: Date
    let changedAt: Date?
    
    init(id: String = UUID().uuidString, text: String, priority: Priority, deadline: Date? = nil, isCompleted: Bool, createdAt: Date, changedAt: Date? = nil) {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        
        guard let id = dict[JsonKeys.taskId] as? String,
              let text = dict[JsonKeys.taskText] as? String,
              let createdAt = (dict[JsonKeys.taskCreatedAt] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) }) else {
            return nil
        }
        
        let priority = parsePriority((dict[JsonKeys.taskPriority] as? String))
        let deadline = (dict[JsonKeys.taskDeadline] as? Int).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        let isCompleted = dict[JsonKeys.taskIsCompleted] as? Bool ?? false
        let changedAt = (dict[JsonKeys.taskChangedAt] as? Int).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        
        return TodoItem(id: id, text: text, priority: priority, deadline: deadline, isCompleted: isCompleted, createdAt: createdAt, changedAt: changedAt)
    }
    
    var json: Any {
        var jsonDict: [String: Any] = [:]
        jsonDict[JsonKeys.taskId] = id
        jsonDict[JsonKeys.taskText] = text
        
        if priority != .medium {
            jsonDict[JsonKeys.taskPriority] = priority.rawValue
        }
        
        if let deadline {
            jsonDict[JsonKeys.taskDeadline] = Int(deadline.timeIntervalSince1970)
        }
        
        jsonDict[JsonKeys.taskIsCompleted] = isCompleted
        jsonDict[JsonKeys.taskCreatedAt] = Int(createdAt.timeIntervalSince1970)
        
        if let changedAt {
            jsonDict[JsonKeys.taskChangedAt] = Int(changedAt.timeIntervalSince1970)
        }
        
        return jsonDict
    }
    
    var csv: String {
        var csvString = "id,text,priority,deadline,isCompleted,createdAt,changedAt\n"
        
        let deadlineString = deadline != nil ? "\(Int(deadline!.timeIntervalSince1970))" : ""
        let createdAtString = "\(Int(createdAt.timeIntervalSince1970))"
        let changedAtString = changedAt != nil ? "\(Int(changedAt!.timeIntervalSince1970))" : ""
        
        let priorityString = priority != .medium ? priority.rawValue : ""
        
        let row = "\(id),\(text),\(priorityString),\(deadlineString),\(isCompleted),\(createdAtString),\(changedAtString)\n"
        
        csvString.append(row)
        
        return csvString
    }

    static func parse(csv: String) -> TodoItem? {
        let rows = csv.components(separatedBy: "\n")
        guard rows.count > 1 else {
            return nil
        }
        
        let header = rows[0].components(separatedBy: ",")
        let values = rows[1].components(separatedBy: ",")
        
        guard header.count == values.count else {
            return nil
        }
        
        var dict: [String: String] = [:]
        for (index, value) in values.enumerated() {
            dict[header[index]] = value
        }
        
        guard let id = dict["id"],
              let text = dict["text"],
              let createdAtString = dict["createdAt"],
              let createdAt = TimeInterval(createdAtString).map({ Date(timeIntervalSince1970: $0) }) else {
            return nil
        }
        
        let priorityString = dict["priority"]
        let priority = parsePriority(priorityString)
        
        let deadlineString = dict["deadline"]
        let deadline = deadlineString.flatMap { TimeInterval($0) }.flatMap { Date(timeIntervalSince1970: $0) }
        
        guard let isCompletedString = dict["isCompleted"] else {
            return nil
        }
        
        guard let isCompleted = Bool(isCompletedString) else {
            return nil
        }
        
        let changedAtString = dict["changedAt"]
        let changedAt = changedAtString.flatMap { TimeInterval($0) }.flatMap { Date(timeIntervalSince1970: $0) }
        
        return TodoItem(id: id, text: text, priority: priority, deadline: deadline, isCompleted: isCompleted, createdAt: createdAt, changedAt: changedAt)
    }
    
    private static func parsePriority(_ string: String?) -> Priority {
        switch string {
        case "low": return .low
        case "medium": return .medium
        case "high": return .high
        default: return .medium
        }
    }
}
