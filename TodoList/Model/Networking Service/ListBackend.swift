//
//  ListBackend.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 06.07.2023.
//

import Foundation

struct ListBackend: Codable {
    let status: String
    let list: [TodoItemBackend]
    let revision: Int32?
    
    init(status: String = "ok", list: [TodoItemBackend], revision: Int32? = nil) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}
