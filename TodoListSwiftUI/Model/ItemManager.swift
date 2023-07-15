//
//  ItemManager.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 15.07.2023.
//

import Foundation
import SwiftUI

struct ItemManager {
    var item: TodoItem
    
    init(item: TodoItem) {
        self.item = item
    }
    
    var radioImageName: Image {
        var image: Image
        
        if item.priority == .high {
            image = Images.radioButtonHighPriority.image
        } else if item.isCompleted {
            image = Images.radioButtonOn.image
        } else {
            image = Images.radioButtonOff.image
        }
        
        return image
    }
    
    var priorityImageName: Image {
        var image: Image
        
        switch item.priority {
        case .low: image = Images.priorityLow.image
        case .medium: image = Images.priorityLow.image
        case .high: image = Images.priorityHigh.image
        }
        
        return image
    }
    
    var subtitle: String? {
        guard let date = item.deadline else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: date)
    }
    
}
