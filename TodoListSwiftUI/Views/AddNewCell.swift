//
//  AddNewCell.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 16.07.2023.
//

import SwiftUI

struct AddNewCell: View {
    var body: some View {
        HStack(spacing: 12) {
            Images.plusCircle.image
            Text("Новое")
                .font(Fonts.body)
                .foregroundColor(Colors.labelTertiary.color)
        }
        .onTapGesture {
            print("add new item")
        }
    }
}

struct AddNewCell_Previews: PreviewProvider {
    static var previews: some View {
        AddNewCell()
    }
}
