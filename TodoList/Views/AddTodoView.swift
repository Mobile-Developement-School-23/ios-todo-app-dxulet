//
//  AddTodoView.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 22.06.2023.
//

import UIKit

protocol AddTodoViewDelegate: AnyObject {
    func cancelButtonTapped()
    func saveButtonTapped()
    func deleteButtonTapped()
    func didChangePriority(_ priority: Priority)
    func didChangeDeadline(_ deadline: Date)
    func didChangeDeadlineSwitcher(_ isOn: Bool)
    func didChangeText(_ text: String)
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
    
    // MARK: - UI Elements
    
    private lazy var topBar = makeTopBar()
    private lazy var contentStackView = makeContentStackView()
    private lazy var containerView = makeContainerView()
    private lazy var customTextView = makeTextView()
    private lazy var priorityView = makePriorityView()
    private lazy var deadlineView = makeDeadlineView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.cancelTitle, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText
        label.font = GlobalConstants.headline
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.saveTitle, for: .normal)
        return button
    }()
    
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
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.deleteTitle, for: .normal)
        button.layer.cornerRadius = GlobalConstants.cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = .white
        button.setTitleColor(.systemGray2, for: .disabled)
        button.setTitleColor(.red, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        configureUI()
    }
    
    private func addSubviews() {
        addSubview(topBar)
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)
    }
    
    private func configureUI() {
        backgroundColor = UIColor(named: "BackColor")
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                            constant: Constants.topBarInsets.left),
            topBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                   constant: Constants.topBarInsets.right),
            topBar.heightAnchor.constraint(equalToConstant: Constants.topBarHeight),
            
            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: Constants.scrollViewInsets.top),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                constant: Constants.scrollViewInsets.left),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                 constant: Constants.scrollViewInsets.right),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            customTextView.heightAnchor.constraint(equalToConstant: Constants.textViewHeight),
            priorityView.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight),
            deadlineView.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight),
            
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight)
        
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
    
    private func makeTopBar() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            cancelButton,
            titleLabel,
            saveButton
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makeTextView() -> CustomTextView {
        let textView = CustomTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.customDelegate = self
        return textView
    }
    
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
    
    private func makeContentStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            customTextView,
            containerView,
            deleteButton
        ])
        stackView.axis = .vertical
        stackView.spacing = Constants.contentSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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

// MARK: - CustomTextViewDelegate

extension AddTodoView: CustomTextViewDelegate {
    func didChangeText(_ text: String) {
        delegate?.didChangeText(text)
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
        delegate?.didChangeDeadlineSwitcher(isOn)
    }
    
    func deadlineButtonTapped() {
        delegate?.didChangeDeadline(deadlinePicker.date)
    }
}


