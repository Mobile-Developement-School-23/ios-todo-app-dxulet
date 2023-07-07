//
//  ElementBackend.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 06.07.2023.
//

import Foundation

struct ElementBackend: Codable {
    let status: String
    let element: TodoItemBackend?
    let revision: Int32?
    
    init(status: String = "ok", element: TodoItemBackend?, revision: Int32? = nil) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}
