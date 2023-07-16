//
//  SQLiteManager.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 13.07.2023.
//

import Foundation
import SQLite
import TodoModelsYandex

enum TodoItemTable {
    static let table = Table("todoItems")
    static let id = Expression<String>("id")
    static let text = Expression<String>("text")
    static let priority = Expression<String>("priority")
    static let deadline = Expression<Date?>("deadline")
    static let isCompleted = Expression<Bool>("isCompleted")
    static let createdAt = Expression<Date>("createdAt")
    static let changedAt = Expression<Date?>("changedAt")
}

final class SQLiteManager {
    
    private let connection: Connection?
    static let shared = SQLiteManager()
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        do {
            connection = try Connection("\(path)/db.sqlite3")
        } catch {
            connection = nil
            print("Unable to open database")
        }
        createTable()
    }
    
    func createTable() {
        do {
            try connection?.run(TodoItemTable.table.create(ifNotExists: true) { table in
                table.column(TodoItemTable.id, primaryKey: true)
                table.column(TodoItemTable.text)
                table.column(TodoItemTable.priority)
                table.column(TodoItemTable.isCompleted)
                table.column(TodoItemTable.deadline)
                table.column(TodoItemTable.createdAt)
                table.column(TodoItemTable.changedAt)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func insert(item: TodoItem) {
        let insert = TodoItemTable.table.insert(
            TodoItemTable.id <- item.id,
            TodoItemTable.text <- item.text,
            TodoItemTable.priority <- item.priority.rawValue,
            TodoItemTable.deadline <- item.deadline,
            TodoItemTable.isCompleted <- item.isCompleted,
            TodoItemTable.changedAt <- item.changedAt,
            TodoItemTable.createdAt <- item.createdAt
        )
        
        do {
            try connection?.run(insert)
        } catch {
            print("Insert failed")
        }
    }
    
    func update(item: TodoItem) {
        let todoItem = TodoItemTable.table.filter(TodoItemTable.id == item.id)
        let update = todoItem.update(
            TodoItemTable.text <- item.text,
            TodoItemTable.priority <- item.priority.rawValue,
            TodoItemTable.deadline <- item.deadline,
            TodoItemTable.isCompleted <- item.isCompleted,
            TodoItemTable.changedAt <- item.changedAt,
            TodoItemTable.createdAt <- item.createdAt
        )
        
        do {
            try connection?.run(update)
        } catch {
            print("Update failed")
        }
    }
    
    func delete(item: TodoItem) {
        let todoItem = TodoItemTable.table.filter(TodoItemTable.id == item.id)
        let delete = todoItem.delete()
        
        do {
            try connection?.run(delete)
        } catch {
            print("Delete failed")
        }
    }
    
    func fetch() -> [TodoItem] {
        var items = [TodoItem]()
        
        do {
            for item in try (connection?.prepare(TodoItemTable.table))! {
                items.append(TodoItem(
                    id: item[TodoItemTable.id],
                    text: item[TodoItemTable.text],
                    priority: Priority(rawValue: item[TodoItemTable.priority]) ?? .medium,
                    deadline: item[TodoItemTable.deadline],
                    isCompleted: item[TodoItemTable.isCompleted],
                    createdAt: item[TodoItemTable.createdAt],
                    changedAt: item[TodoItemTable.changedAt]))
            }
        } catch {
            print("Select failed")
        }
        
        return items
    }
}
