//
//  AddTodoController.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 22.06.2023.
//

import UIKit

class AddTodoController: UIViewController {
    
    // MARK: - Properties
    
    var didSaveItem: ((TodoItem) -> Void)?
    
    private enum Constants {
        static let cancelTitle = "Отменить"
        static let titleText = "Дело"
        static let saveTitle = "Сохранить"
        static let deleteTitle = "Удалить"
        static let backgroundColor = UIColor(named: "BackColor")
        static let contentSpacing: CGFloat = 16
        static let scrollViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        static let topBarHeight: CGFloat = 50
        static let textViewHeight: CGFloat = 120
        static let containerViewHeight: CGFloat = 60
        static let topBarInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        static let stackViewWidth: CGFloat = -32
        static let topBarSpacing: CGFloat = 10
        static let cornerRadius: CGFloat = 16
    }
    
    private let item: TodoItem?
    private var presentationModel = AddTodoPresentationModel()
    
    // MARK: - Init
    
    init(item: TodoItem? = nil) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    
    private lazy var topBar = makeTopBar()
    private lazy var textView = makeTextView()
    private lazy var addTodoView = makeAddTodoView()
    private lazy var stackView = makeStackView()
    
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
        button.addTarget(self, action: #selector(topBarButtonTapped), for: .touchUpInside)
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
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemGray2, for: .disabled)
        button.isEnabled = false
        button.addTarget(self, action: #selector(topBarButtonTapped), for: .touchUpInside)
        return button
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = Constants.backgroundColor
        
        view.addSubview(topBar)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.topBarInsets.left),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.topBarInsets.right),
            topBar.heightAnchor.constraint(equalToConstant: Constants.topBarHeight),
            
            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.scrollViewInsets.left),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Constants.scrollViewInsets.right),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: Constants.stackViewWidth),
            
            textView.heightAnchor.constraint(equalToConstant: Constants.textViewHeight),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight)
        ])
    }
    
    private func makeTextView() -> CustomTextView {
        let textView = CustomTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
    
    private func makeAddTodoView() -> AddTodoView {
        let view = AddTodoView(item: item)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
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
    
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            textView,
            addTodoView,
            deleteButton
        ])
        stackView.axis = .vertical
        stackView.spacing = Constants.contentSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    // MARK: - Selectors
    
    @objc private func topBarButtonTapped(selector: UIButton) {
        switch selector {
        case cancelButton:
            print("cancel button tapped")
//            dismiss(animated: true)
        case saveButton:
            guard let text = presentationModel.text else { return }
            let todoItem = TodoItem(text: text, priority: presentationModel.priority, deadline: presentationModel.dueDate, isCompleted: false, createdAt: Date())
            didSaveItem?(todoItem)
//            dismiss(animated: true)
        default:
            break
        }
    }
    
    @objc private func deleteButtonTapped() {
        //        presentationModel.deleteItem()
        //        dismiss(animated: true)
    }
}

// MARK: - AddTodoViewDelegate

extension AddTodoController: AddTodoViewDelegate {
    
    func didChangePriority(_ priority: Priority) {
        presentationModel.priority = priority
    }
    
    func didChangeDeadline(_ deadline: Date) {
        presentationModel.dueDate = deadline
    }
}

