//
//  ConfiguredTableView.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 09.07.2023.
//

import UIKit

final class ConfiguredTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
