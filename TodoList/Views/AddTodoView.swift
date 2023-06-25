//
//  AddTodoView.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 22.06.2023.
//

import UIKit

protocol AddTodoViewDelegate: AnyObject {
    func didChangePriority(_ priority: Priority)
    func didChangeDeadline(_ deadline: Date)
}

class AddTodoView: UIView {
    
    // MARK: - Properties
    
    private enum Constants {
        static let cancelTitle = "Отменить"
        static let titleText = "Дело"
        static let saveTitle = "Сохранить"
        static let deleteTitle = "Удалить"
        static let contentSpacing: CGFloat = 16
        static let scrollViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        static let topBarHeight: CGFloat = 50
        static let textViewHeight: CGFloat = 120
        static let containerViewHeight: CGFloat = 60
        static let topBarInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        static let topBarSpacing: CGFloat = 10
        static let cornerRadius: CGFloat = 16
    }
    
    weak var delegate: AddTodoViewDelegate?
    private let item: TodoItem?
    
    
    // MARK: - UI Elements
    
    private lazy var containerView = makeContainerView()
    private lazy var priorityView = makePriorityView()
    private lazy var deadlineView = makeDeadlineView()
    
    private let deadlinePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.addTarget(self, action: #selector(deadlinePickerTapped(sender:)), for: .valueChanged)
        picker.isHidden = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        return picker
    }()
    
    // MARK: - Init
    
    init(item: TodoItem?) {
        self.item = item
        super.init(frame: .zero)
        
        addSubviews()
        configureUI()
    }
    
    private func addSubviews() {
        addSubview(containerView)
    }
    
    private func configureUI() {
        backgroundColor = UIColor(named: "BackColor")
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            
            priorityView.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight),
            deadlineView.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func deadlinePickerTapped(sender: UIDatePicker) {
        print(sender.date)
    }
    
    @objc func deleteButtonTapped() {
        print("deleteButtonTapped")
    }
    
    // MARK: - Lifecycle
    
    private func makePriorityView() -> PriorityView {
        let view = PriorityView()
        view.delegate = self
        return view
    }
    
    private func makeDeadlineView() -> DeadlineCalendarView {
        let view = DeadlineCalendarView()
        view.delegate = self
        return view
    }
    
    private func makeContainerView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [
            priorityView,
            deadlineView,
            deadlinePicker
        ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }

}

// MARK: - PriorityViewDelegate

extension AddTodoView: PriorityViewDelegate {
    func priorityChanged(_ priority: Priority) {
        delegate?.didChangePriority(priority)
    }
}

// MARK: - DeadlineCalendarViewDelegate

extension AddTodoView: DeadlineCalendarViewDelegate {
    func deadlineSwitcherChanged(_ isOn: Bool) {
        
    }
    
    func deadlineButtonTapped() {
        
    }
}


