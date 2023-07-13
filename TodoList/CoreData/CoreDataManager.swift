//
//  CoreDataManager.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 13.07.2023.
//

import CoreData
import TodoModelsYandex

struct CoreDataManager {
    
    private let coreDataStack: CoreDataStack
    
    init(modelName: String) {
        coreDataStack = CoreDataStack(modelName: modelName)
    }
    
    func save(_ item: TodoItem) {
        let coreItem = CoreTodoItem(context: coreDataStack.managedContext)
        coreItem.id = item.id
        coreItem.text = item.text
        coreItem.priority = item.priority.rawValue
        coreItem.deadline = item.deadline
        coreItem.isCompleted = item.isCompleted
        coreItem.createdAt = item.createdAt
        coreItem.changedAt = item.changedAt
        
        coreDataStack.saveContext()
    }
    
    func fetch() -> [TodoItem] {
        let fetchRequest = NSFetchRequest<CoreTodoItem>(entityName: "CoreTodoItem")
        
        let coreItems = try? coreDataStack.managedContext.fetch(fetchRequest)
        
        return coreItems?.map { coreItem in
            TodoItem(
                id: coreItem.id,
                text: coreItem.text,
                priority: Priority(rawValue: coreItem.priority) ?? .medium,
                deadline: coreItem.deadline,
                isCompleted: coreItem.isCompleted,
                createdAt: coreItem.createdAt,
                changedAt: coreItem.changedAt
            )
        } ?? []
    }
    
    func update(_ item: TodoItem) {
        let fetchRequest = NSFetchRequest<CoreTodoItem>(entityName: "CoreTodoItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
        
        let coreItems = try? coreDataStack.managedContext.fetch(fetchRequest)
        
        guard let coreItem = coreItems?.first else { return }
        
        coreItem.text = item.text
        coreItem.priority = item.priority.rawValue
        coreItem.deadline = item.deadline
        coreItem.isCompleted = item.isCompleted
        coreItem.changedAt = item.changedAt
        
        coreDataStack.saveContext()
    }
    
    func delete(_ item: TodoItem) {
        let fetchRequest = NSFetchRequest<CoreTodoItem>(entityName: "CoreTodoItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
        
        let coreItems = try? coreDataStack.managedContext.fetch(fetchRequest)
        
        guard let coreItem = coreItems?.first else { return }
        
        coreDataStack.managedContext.delete(coreItem)
        coreDataStack.saveContext()
    }
}
