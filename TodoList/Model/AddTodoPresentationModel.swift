//
//  AddTodoPresentationModel.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 24.06.2023.
//

import Foundation
import UIKit
import TodoModelsYandex

struct AddTodoPresentationModel {

    var id: String?
    var text: String?
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var dueDate: Date?

    var isHiddenSubtitle: Bool {
        dueDate == nil
    }

    var priorityIsHidden: Bool {
        priority == .medium || isCompleted
    }

    var priorityImage: UIImage? {
        switch priority {
        case .high:
            return Images.priorityHigh.image
        case .low:
            return Images.priorityLow.image
        case .medium:
            return nil
        }
    }

    var title: NSMutableAttributedString? {
        guard let text = text else { return nil }
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }

    var subtitle: String? {
        guard let date = dueDate else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: date)
    }

    init(from todoItem: TodoItem) {
        id = todoItem.id
        text = todoItem.text
        isCompleted = todoItem.isCompleted
        priority = todoItem.priority
        dueDate = todoItem.deadline
    }

    init(textInput: String = "") {
        text = textInput
    }
}
