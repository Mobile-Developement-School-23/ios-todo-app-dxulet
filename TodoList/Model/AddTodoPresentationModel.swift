//
//  AddTodoPresentationModel.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 24.06.2023.
//

import Foundation

struct AddTodoPresentationModel {
    
    var id: String?
    var text: String?
    var priority: Priority = .medium
    var dueDate: Date?
    
    init(from todoItem: TodoItem) {
        id = todoItem.id
        text = todoItem.text
        priority = todoItem.priority
        dueDate = todoItem.deadline
    }
    
    init(textInput: String = "") {
        text = textInput
    }
}
