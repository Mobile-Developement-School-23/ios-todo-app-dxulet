//
//  Colors.swift
//  TodoListSwiftUI
//
//  Created by Daulet Ashikbayev on 15.07.2023.
//

import Foundation
import SwiftUI

enum Colors {
    case backElevated
    case backIOSPrimary
    case backPrimary
    case backSecondary
    case colorBlue
    case colorGrayLight
    case colorGray
    case colorGreen
    case colorRed
    case colorWhite
    case labelDisable
    case labelPrimary
    case labelSecondary
    case labelTertiary
    case supportNavBarBlur
    case supportOverlay
    case supportSeparator
}

extension Colors {
    var color: Color {
        var color: Color?
        
        switch self {
        case .backElevated:
            color = Color("back_elevated")
        case .backIOSPrimary:
            color = Color("back_ios_primary")
        case .backPrimary:
            color = Color("back_primary")
        case .backSecondary:
            color = Color("back_secondary")
        case .colorBlue:
            color = Color("color_blue")
        case .colorGrayLight:
            color = Color("color_gray_light")
        case .colorGray:
            color = Color("color_gray")
        case .colorGreen:
            color = Color("color_green")
        case .colorRed:
            color = Color("color_red")
        case .colorWhite:
            color = Color("color_white")
        case .labelDisable:
            color = Color("label_disable")
        case .labelPrimary:
            color = Color("label_primary")
        case .labelSecondary:
            color = Color("label_secondary")
        case .labelTertiary:
            color = Color("label_tertiary")
        case .supportNavBarBlur:
            color = Color("support_nav_bar_blur")
        case .supportOverlay:
            color = Color("support_overlay")
        case .supportSeparator:
            color = Color("support_separator")
        }
        
        return color ?? Color(.clear)
    }
}
