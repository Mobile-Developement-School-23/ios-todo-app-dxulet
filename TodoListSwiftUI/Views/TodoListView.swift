//
//  TodoListView.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 15.07.2023.
//

import SwiftUI

struct TodoListView: View {
    var body: some View {
        
        NavigationView {
            List {
                Section {
                    ForEach(MockItems.items) { item in
                        TodoItemCell(item: item, itemManager: ItemManager(item: item))
                    }
    
                    .padding(.vertical, 8)
                    AddNewCell()
                } header: {
                    HStack {
                        Text("Выполнено — 0")
                            .font(Fonts.subhead)
                            .foregroundColor(Colors.labelTertiary.color)
                            .textCase(.none)
                        Spacer()
                        Text("Показать")
                            .foregroundColor(Colors.colorBlue.color)
                            .font(Fonts.subheadBold)
                            .textCase(.none)
                    }
                }
            }
            .environment(\.defaultMinListRowHeight, 56)
            .background(Colors.backPrimary.color)
            .scrollContentBackground(.hidden)
            .navigationTitle("Мои Дела")
            .navigationBarTitleDisplayMode(.large)
        }
        .overlay(
            Button(action: {
                // Action to be performed when the plus button is tapped
            }) {
                Images.addLarge.image
            }, alignment: .bottom
        )
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}

