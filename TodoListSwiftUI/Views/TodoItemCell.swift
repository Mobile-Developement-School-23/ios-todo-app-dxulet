//
//  TodoItemCell.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 15.07.2023.
//

import SwiftUI

struct TodoItemCell: View {
    let item: TodoItem
    let itemManager: ItemManager
    
    var body: some View {
        HStack(spacing: 12) {
            itemManager.radioImageName
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    itemManager.priorityImageName
                    Text(item.text)
                        .font(Fonts.body)
                        .lineLimit(3)
                        .foregroundColor(Colors.labelPrimary.color)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                
                HStack(alignment: .center, spacing: 2) {
                    if item.deadline != nil {
                        Images.calendar.image
                            .foregroundColor(Colors.labelTertiary.color)
                        Text(itemManager.subtitle!)
                            .font(Fonts.subhead)
                            .foregroundColor(Colors.labelTertiary.color)
                    }
                }
            }
            Spacer()
            Images.chevron.image
        }
    }
}

struct TodoItemCell_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemCell(item: MockItems.items[0], itemManager: ItemManager(item: MockItems.items[0]))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
