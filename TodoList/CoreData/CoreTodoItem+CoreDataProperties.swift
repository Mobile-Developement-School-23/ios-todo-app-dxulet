//
//  CoreTodoItem+CoreDataProperties.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 13.07.2023.
//
//

import Foundation
import CoreData
import TodoModelsYandex

extension CoreTodoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreTodoItem> {
        return NSFetchRequest<CoreTodoItem>(entityName: "CoreTodoItem")
    }

    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var priority: String
    @NSManaged public var deadline: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var changedAt: Date?
}

extension TodoItem : Identifiable {}
