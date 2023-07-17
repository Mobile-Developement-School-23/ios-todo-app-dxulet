//
//  AddItemView.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 16.07.2023.
//

import SwiftUI

struct AddItemView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var item: TodoItem
    
    var body: some View {
        NavigationView {
            List {
                TextField("Что надо сделать?", text: $item.text)
                    .frame(minHeight: 120, alignment: .topLeading)
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Важность")
                                .font(Fonts.body)
                                .foregroundColor(Colors.labelPrimary.color)
                            Spacer()
                            Picker(selection: $item.priority, label: Text("Picker")) {
                                Images.priorityLow.image.tag(Priority.low)
                                Text("нет").tag(Priority.medium)
                                Images.priorityHigh.image.tag(Priority.high)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 150)
                        }
                        Divider()
                        Toggle("Сделать до", isOn: .constant(true))
                    }
                }
                HStack(alignment: .center, spacing: 16) {
                    Button("Удалить") {
                        print("delete tapped")
                    }
                    .disabled(true)
                }
                .frame(maxWidth: .infinity, minHeight: 40)
            }
            .scrollContentBackground(.hidden)
            .background(Colors.backPrimary.color)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Отменить")
                            .font(Fonts.body)
                            .foregroundColor(Colors.colorBlue.color)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Text("Сохранить")
                        .font(Fonts.headline)
                        .foregroundColor(Colors.colorGray.color)
                }
            }
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    @State static var item = MockItems.items[0]
    
    static var previews: some View {
        AddItemView(item: $item)
    }
}
