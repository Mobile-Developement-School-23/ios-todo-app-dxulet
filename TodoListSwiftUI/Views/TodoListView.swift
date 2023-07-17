//
//  TodoListView.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 15.07.2023.
//

import SwiftUI

struct TodoListView: View {
    
    @State var selectedItemPresented = false
    @State var isAddItemPresented = false
    @State var selectedItem = TodoItem()
    @State var item = TodoItem()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(MockItems.items) { item in
                        TodoItemCell(item: item, itemManager: ItemManager(item: item))
                            .onTapGesture {
                                self.selectedItem = item
                                selectedItemPresented.toggle()
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    print("Favorite")
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                .tint(Colors.colorGreen.color)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    print("Delete")
                                } label: {
                                    Image(systemName: "trash.fill")
                                }
                                .tint(Colors.colorRed.color)
                                
                                Button {
                                    self.selectedItem = item
                                    selectedItemPresented.toggle()
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                }
                                .tint(Colors.colorGrayLight.color)
                            }
                    }
                    .padding(.vertical, 8)
                    AddNewCell()
                        .onTapGesture {
                            isAddItemPresented.toggle()
                        }
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
                isAddItemPresented.toggle()
            }) {
                Images.addLarge.image
            }, alignment: .bottom
        )
        .sheet(isPresented: $isAddItemPresented) {
            AddItemView(item: $item)
        }
        
        .sheet(isPresented: $selectedItemPresented) {
            AddItemView(item: $selectedItem)
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}

