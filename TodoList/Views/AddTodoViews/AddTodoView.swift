//
//  AddTodoView.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 22.06.2023.
//

import UIKit

protocol AddTodoViewDelegate: AnyObject {
    func didChangePriority(_ priority: Priority)
    func didChangeDeadline(_ deadline: Date?)
}

class AddTodoView: UIView {
    
    // MARK: - Properties
    
    private enum Constants {
        static let containerViewHeight: CGFloat = 60
        static let dividerHeight: CGFloat = 0.5
        static let cornerRadius: CGFloat = 16
        static let nextDay = Date.now.addingTimeInterval(86400)
        static let dividerInsetInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        
    }
    
    weak var delegate: AddTodoViewDelegate?
    private var presentationModel: AddTodoPresentationModel?
    
    
    // MARK: - UI Elements
    
    private lazy var containerView = makeContainerView()
    private lazy var priorityView = makePriorityView()
    private lazy var deadlineView = makeDeadlineView()
    private lazy var deadlinePicker = makeDeadlinePicker()
    
    // MARK: - Init
    
    init(presentationModel: AddTodoPresentationModel?) {
        self.presentationModel = presentationModel
        super.init(frame: .zero)
        
        addSubviews()
        configureUI()
    }
    
    private func addSubviews() {
        addSubview(containerView)
    }
    
    private func configureUI() {
        
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
        delegate?.didChangeDeadline(sender.date)
        deadlineView.setDeadlineButtonTitle(sender.date)
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
    
    private func makeDeadlinePicker() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.minimumDate = Constants.nextDay
        picker.preferredDatePickerStyle = .inline
        picker.addTarget(self, action: #selector(deadlinePickerTapped(sender:)), for: .valueChanged)
        picker.isHidden = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }
    
    private func makeContainerView() -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = Colors.backSecondary.color
        
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
    
    func update(with item: TodoItem) {
        priorityView.update(with: item.priority)
        deadlineView.update(with: item.deadline)
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
    
    func deadlineSwitcherChanged(_ switcher: UISwitch) {
        if switcher.isOn {
            delegate?.didChangeDeadline(Constants.nextDay)
            deadlinePicker.setDate(Constants.nextDay, animated: true)
            deadlineView.updateLayoutSwitch(for: Constants.nextDay)
        } else {
            delegate?.didChangeDeadline(nil)
            UIView.animate(withDuration: 0.3) {
                self.deadlinePicker.isHidden = true
            }
            deadlineView.updateLayoutSwitch(for: nil)
        }
    }
    
    func deadlineButtonTapped() {
        if deadlinePicker.isHidden {
            UIView.animate(withDuration: 0.3) {
                self.deadlinePicker.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.deadlinePicker.isHidden = true
            }
        }
        
        deadlinePicker.setDate(Constants.nextDay, animated: true)
    }
}


