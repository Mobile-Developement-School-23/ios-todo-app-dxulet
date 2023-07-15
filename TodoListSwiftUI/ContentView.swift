//
//  ContentView.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 15.07.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TodoListView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
