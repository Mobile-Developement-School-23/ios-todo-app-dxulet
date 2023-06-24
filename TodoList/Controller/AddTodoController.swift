//
//  AddTodoController.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 22.06.2023.
//

import UIKit

class AddTodoController: UIViewController {
    
    // MARK: - Properties
    
    private var presentationModel: AddTodoPresentationModel

    // MARK: - Subviews

    private lazy var addTodoView = makeAddTodoView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        
        view.addSubview(addTodoView)
        addTodoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addTodoView.topAnchor.constraint(equalTo: view.topAnchor),
            addTodoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addTodoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addTodoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func makeAddTodoView() -> AddTodoView {
        let view = AddTodoView()
        view.delegate = self
        return view
    }
}

// MARK: - AddTodoViewDelegate

extension AddTodoController: AddTodoViewDelegate {
    func cancelButtonTapped() {
        <#code#>
    }
    
    func saveButtonTapped() {
        <#code#>
    }
    
    func deleteButtonTapped() {
        <#code#>
    }
    
    func didChangePriority(_ priority: Priority) {
        presentationModel.priority = priority
    }
    
    func didChangeDeadline(_ deadline: Date) {
        <#code#>
    }
    
    func didChangeDeadlineSwitcher(_ isOn: Bool) {
        <#code#>
    }
    
    func didChangeText(_ text: String) {
        presentationModel.text = text
        guard presentationModel.text?.count > 0 else {
            addTodoView.saveButton.isEnabled = false
            return
        }
    }
    
    
}

