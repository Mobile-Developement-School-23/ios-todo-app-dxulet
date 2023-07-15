//
//  Images.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 15.07.2023.
//

import Foundation
import SwiftUI

enum Images {
    case plusCircle
    case radioButtonHighPriority
    case radioButtonOff
    case radioButtonOn
    case addSmall
    case addLarge
    case calendar
    case chevron
    case priorityHigh
    case priorityLow
    case showOff
    case showOn
}

extension Images {
    var image: Image {
        var image: Image

        switch self {
        case .plusCircle:
            image = Image("plus_circle_24x24")
        case .radioButtonHighPriority:
            image = Image("radio_button_high_priority_24x24")
        case .radioButtonOff:
            image = Image("radio_button_off_24x24")
        case .radioButtonOn:
            image = Image("radio_button_on_24x24")
        case .addSmall:
            image = Image("add_small")
        case .addLarge:
            image = Image("add_large")
        case .calendar:
            image = Image("calendar")
        case .chevron:
            image = Image("chevron")
        case .priorityHigh:
            image = Image("priority_high")
        case .priorityLow:
            image = Image("priority_low")
        case .showOff:
            image = Image("show_off")
        case .showOn:
            image = Image("show_on")
        }

        return image
    }
}

