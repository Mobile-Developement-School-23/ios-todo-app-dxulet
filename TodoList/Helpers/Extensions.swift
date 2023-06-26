//
//  Extensions.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 26.06.2023.
//

import UIKit

extension UIViewController {
    func setupKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
    }
}
