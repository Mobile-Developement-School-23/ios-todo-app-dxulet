//
//  AddTodoController.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 22.06.2023.
//

import UIKit
import TodoModelsYandex

protocol AddTodoControllerDelegate: AnyObject {
    func addViewControllerDidSave(_: AddTodoController, item: TodoItem)
    func addViewControllerDidDelete(_: AddTodoController, item: TodoItem)
}

class AddTodoController: UIViewController {

    // MARK: - Properties

    private var fileCache: FileCache = FileCache()
    private let coreDataStack: CoreDataStack = .init(modelName: "FileCacheData")

    private enum Constants {
        static let cancelTitle = "Отменить"
        static let titleText = "Дело"
        static let saveTitle = "Сохранить"
        static let deleteTitle = "Удалить"
        static let alertTitle = "Успех"
        static let alertMessage = "Новое дело успешно сохранено"
        static let alertActionTitle = "Ок"
        static let placeholder = "Что надо сделать?"
        static let contentSpacing: CGFloat = 16
        static let scrollViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        static let topBarHeight: CGFloat = 50
        static let textViewHeight: CGFloat = 120
        static let containerViewHeight: CGFloat = 60
        static let topBarInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        static let stackViewWidth: CGFloat = -32
    }

    private var item: TodoItem
    private var presentationModel = AddTodoPresentationModel()
    weak var delegate: AddTodoControllerDelegate?

    // MARK: - Init

    init(_ item: TodoItem) {
        self.item = item
        presentationModel = AddTodoPresentationModel(from: item)
        super.init(nibName: nil, bundle: nil)
        updateVC(with: item)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Subviews

    private lazy var topBar = makeTopBar()
    private lazy var textView = makeTextView()
    private lazy var addTodoView = makeAddTodoView()
    private lazy var stackView = makeStackView()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = GlobalConstants.body
        button.setTitle(Constants.cancelTitle, for: .normal)
        button.addTarget(self, action: #selector(topBarButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText
        label.font = GlobalConstants.headline
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.saveTitle, for: .normal)
        button.titleLabel?.font = GlobalConstants.headline
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemGray2, for: .disabled)
        button.isEnabled = false
        button.addTarget(self, action: #selector(topBarButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.deleteTitle, for: .normal)
        button.layer.cornerRadius = GlobalConstants.cornerRadius
        button.layer.masksToBounds = true
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
        setupKeyboard()
        setupObservers()
    }

    // MARK: - Private Methods

    private func setupColors() {
        view.backgroundColor = Colors.backPrimary.color
        textView.backgroundColor = Colors.backSecondary.color
        titleLabel.textColor = Colors.labelPrimary.color
        deleteButton.backgroundColor = Colors.backSecondary.color
        [cancelButton, saveButton].forEach { $0.setTitleColor(Colors.colorBlue.color, for: .normal) }
        saveButton.setTitleColor(Colors.labelTertiary.color, for: .disabled)
    }

    private func setupView() {

        setupColors()

        view.addSubview(topBar)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        view.keyboardLayoutGuide.followsUndockedKeyboard = true

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

            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textViewHeight),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight)
        ])
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        prepareViewsAccordingToOrientation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prepareViewsAccordingToOrientation()
    }

    private func prepareViewsAccordingToOrientation() {
        if traitCollection.verticalSizeClass == .compact && textView.text != Constants.placeholder {
            // landscape
            addTodoView.isHidden = true
            deleteButton.isHidden = true
        } else {
            // normal
            addTodoView.isHidden = false
            deleteButton.isHidden = false
        }
    }

    private func makeTextView() -> CustomTextView {
        let textView = CustomTextView()
        textView.customDelegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }

    private func makeAddTodoView() -> AddTodoView {
        let view = AddTodoView(presentationModel: presentationModel)
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

    private func updateVC(with item: TodoItem) {
        textView.update(with: item.text)
        addTodoView.update(with: item)
    }

    // MARK: - Selectors

    @objc private func topBarButtonTapped(selector: UIButton) {
        switch selector {
        case cancelButton:
            dismiss(animated: true)
        case saveButton:
            guard let text = presentationModel.text else { return }
            let todoItem = TodoItem(id: item.id, text: text, priority: presentationModel.priority, deadline: presentationModel.dueDate, isCompleted: false, createdAt: Date())
            delegate?.addViewControllerDidSave(self, item: todoItem)
            dismiss(animated: true)
        default:
            break
        }
    }

    @objc private func deleteButtonTapped() {
        delegate?.addViewControllerDidDelete(self, item: item)
        dismiss(animated: true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let nsValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }

        let keyboardSize = nsValue.cgRectValue
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
    }

    @objc private func keyboardWillHide() {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
    }
}

// MARK: - CustomTextViewDelegate

extension AddTodoController: CustomTextViewDelegate {

    func didChangeText(_ text: String) {
        presentationModel.text = text
        saveButton.isEnabled = !text.isEmpty && text != Constants.placeholder
        deleteButton.isEnabled = !text.isEmpty && text != Constants.placeholder
    }
}
// MARK: - AddTodoViewDelegate

extension AddTodoController: AddTodoViewDelegate {

    func didChangePriority(_ priority: Priority) {
        presentationModel.priority = priority
    }

    func didChangeDeadline(_ deadline: Date?) {
        presentationModel.dueDate = deadline
    }
}
