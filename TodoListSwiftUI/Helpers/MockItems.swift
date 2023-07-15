//
//  MockItems.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 15.07.2023.
//

import Foundation
import SwiftUI

enum MockItems {
    static let items = [
        TodoItem(text: "buy milk", priority: .high, deadline: Date(timeIntervalSinceNow: 43434), isCompleted: false, createdAt: Date()),
        TodoItem(text: "buy bread", priority: .high, deadline: Date(timeIntervalSinceNow: 43434), isCompleted: false, createdAt: Date()),
        TodoItem(text: "buy butter", priority: .low, isCompleted: false, createdAt: Date()),
        TodoItem(text: "buy eggs", priority: .high, isCompleted: false, createdAt: Date()),
        TodoItem(text: "buy cheese", priority: .medium, isCompleted: false, createdAt: Date()),
        TodoItem(text: "buy salt", priority: .low, isCompleted: false, createdAt: Date()),
        TodoItem(text: "buy sugar", priority: .high, isCompleted: false, createdAt: Date())
    ]
}
