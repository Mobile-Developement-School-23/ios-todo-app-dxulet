//
//  CustomTextView.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 23.06.2023.
//

import UIKit

protocol CustomTextViewDelegate: AnyObject {
    func didChangeText(_ text: String)
}

class CustomTextView: UITextView {
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let containerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let placeholder = "Что надо сделать?"
        static let placeholderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    weak var customDelegate: CustomTextViewDelegate?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        delegate = self
        font = GlobalConstants.body
        textColor = Constants.placeholderColor
        textContainerInset = Constants.containerInset
        layer.cornerRadius = Constants.cornerRadius
        autocorrectionType = .no
        isScrollEnabled = false
        text = Constants.placeholder
    }
}

extension CustomTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == Constants.placeholder {
            textView.text = nil
            textView.textColor = .black
        }
    }
        
    func textViewDidEndEditing(_ textView: UITextView) {
        customDelegate?.didChangeText(textView.text)
        
        if textView.text.isEmpty {
            textView.text = Constants.placeholder
            textView.textColor = Constants.placeholderColor
        }
    }
}
