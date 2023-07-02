//
//  DividerView.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 27.06.2023.
//

import UIKit

class DividerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Colors.supportSeparator.color
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
