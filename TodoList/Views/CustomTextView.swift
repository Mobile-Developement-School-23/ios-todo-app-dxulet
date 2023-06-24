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
    
    // MARK: - Properties
    
    private enum Constants {
        static let borderColor: CGColor = UIColor.systemGray.cgColor
        static let placeholderText = "Что надо сделать?"
        static let placeholderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        static let textInsets = UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16)
    }
    
    weak var customDelegate: CustomTextViewDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        configureUI()
        addTextViewGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func configureUI() {
        delegate = self
        font = GlobalConstants.body
        backgroundColor = .white
        layer.cornerRadius = GlobalConstants.cornerRadius
        layer.masksToBounds = true
        textContainerInset = Constants.textInsets
    }
    
    // MARK: - Helpers
    
    private func addTextViewGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    private func configurePlaceholder() {
        if text.isEmpty {
            text = Constants.placeholderText
            textColor = Constants.placeholderColor
        } else {
            textColor = .black
        }
    }
    
    // MARK: - Selector
    
    @objc private func handleTap() {
        becomeFirstResponder()
    }
}
    
    // MARK: - UITextViewDelegate
    
    extension CustomTextView: UITextViewDelegate {
        func textViewDidChange(_ textView: UITextView) {
            guard let text = textView.text else { return }
            customDelegate?.didChangeText(text)
            
            if text == Constants.placeholderText  || text.isEmpty {
                let newPosition = textView.beginningOfDocument
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                configurePlaceholder()
            } else {
                textColor = .black
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if text == Constants.placeholderText {
                let newPosition = textView.beginningOfDocument
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            configurePlaceholder()
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
    }
