//
//  TodoListController.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 27.06.2023.
//

import UIKit

class TodoListController: UIViewController {
    
    private enum Constants {
        static let reuseIdentifier: String = "TodoItemCell"
        static let headerReuseIdentifier: String = "HeaderViewCell"
        static let placeholder: String = "Что надо сделать?"
    }
    
    // MARK: - Properties
    
    private var items: [TodoItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var showDoneItems: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var doneCount: Int = 0
    
    private var filteredItems: [TodoItem] {
        if showDoneItems {
            return items
        } else {
            return items.filter { !$0.isCompleted }
        }
    }
    
    private var fileCache = FileCache()
    
    private lazy var headerView = makeHeaderView()
    private lazy var tableView = makeTableView()
    private lazy var addButton = makeAddButton()
    private lazy var footerView = makeFooterView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        loadItems()
    }
    
    // MARK: - Private
    
    private func loadItems() {
        do {
            try fileCache.load(from: "Items")
            items = Array(fileCache.items.values)
        } catch {
            print("DEBUG: Error while loading from JSON file")
        }
    }
    
    private func configureUI() {
        [headerView, tableView, addButton].forEach { view.addSubview($0) }
        configureColors()
        configureNavigationBar()
        configureConstraints()
    }
    
    private func configureColors() {
        navigationController?.navigationBar.backgroundColor = Colors.backPrimary.color
        view.backgroundColor = Colors.backPrimary.color
        tableView.backgroundColor = Colors.backSecondary.color
    }
    
    private func configureNavigationBar() {
        title = "Мои Дела" // TODO: Localize
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func configureConstraints() {
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    // MARK: - Factories
    
    private func makeHeaderView() -> HeaderViewCell {
        let headerView = HeaderViewCell()
        headerView.configure(doneCount: doneCount, showDoneItems: showDoneItems)
        headerView.delegate = self
        return headerView
    }
    
    private func makeFooterView() -> FooterViewCell {
        let footerView = FooterViewCell()
        footerView.delegate = self
        return footerView
    }
    
    private func updateDoneCount() {
        doneCount = items.filter { $0.isCompleted }.count
        headerView.updateDoneCount(doneCount)
    }
    
    private func makeTableView() -> UITableView {
        let tableView = UITableView()
        
        tableView.register(TodoItemCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 56
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }
    
    private func makeAddButton() -> UIButton {
        let button = UIButton()
        button.setImage(Images.addLarge.image, for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    // MARK: - Selectors
    
    @objc private func addButtonTapped() {
        let controller = AddTodoController(TodoItem(text: Constants.placeholder, priority: .medium, isCompleted: false, createdAt: Date()))
        controller.delegate = self
        present(controller, animated: true)
    }
    
    // MARK: - Helpers
    
    private func saveItem() {
        do {
            try fileCache.saveToJSONFile()
            items = Array(fileCache.items.values)
        } catch {
            print("DEBUG: Error while saving to JSON file")
        }
    }
}

// MARK: - UITableViewDelegate

extension TodoListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let controller = AddTodoController(item)
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !items.isEmpty else { return nil }
        let completed = UIContextualAction(style: .normal,
                                           title: "Выполнено") { (_, _, completion) in
            var item = self.items[indexPath.row]
            item.isCompleted.toggle()
            self.fileCache.add(item)
            self.saveItem()
        }
        
        completed.image = UIImage(systemName: "checkmark.circle.fill")
        completed.backgroundColor = Colors.colorGreen.color
        
        return UISwipeActionsConfiguration(actions: [completed])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive,
                                        title: "Удалить") { (_, _, _) in
            let id = self.items[indexPath.row].id
            self.fileCache.remove(id)
            self.saveItem()
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = Colors.colorRed.color
        
        let info = UIContextualAction(style: .normal,
                                      title: "Инфо") { (_, _, _) in
            let item = self.items[indexPath.row]
            let controller = AddTodoController(item)
            controller.delegate = self
            self.present(controller, animated: true)
        }
        info.image = UIImage(systemName: "info.circle.fill")
        info.backgroundColor = Colors.colorGrayLight.color
        
        return UISwipeActionsConfiguration(actions: [delete, info])
    }
}

// MARK: - UITableViewDataSource

extension TodoListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        doneCount = filteredItems.filter({$0.isCompleted}).count
        updateDoneCount()
        return filteredItems.count // TODO: Replace with actual data count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath) as! TodoItemCell
        cell.configure(with: AddTodoPresentationModel(from: filteredItems[indexPath.row]))
        cell.delegate = self
        return cell
    }
}

extension TodoListController: AddTodoControllerDelegate {
    func addViewControllerDidDelete(_: AddTodoController, item: TodoItem) {
        fileCache.remove(item.id)
        saveItem()
    }
    
    func addViewControllerDidSave(_: AddTodoController, item: TodoItem) {
        fileCache.add(item)
        saveItem()
    }
}

extension TodoListController: TodoItemCellDelegate {
    func radioButtonTapped(_ cell: TodoItemCell, isSelected: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var item = items[indexPath.row]
        item.isCompleted = isSelected
        fileCache.add(item)
        saveItem()
    }
}

extension TodoListController: HeaderViewCellDelegate {
    func showDoneItemsButtonTapped(_: HeaderViewCell, didSelectShowButton isSelected: Bool) {
        showDoneItems = isSelected
    }
}

extension TodoListController: FooterViewCellDelegate {
    func footerViewCellDidTapAddNewButton(_ footerViewCell: FooterViewCell) {
        let controller = AddTodoController(TodoItem(text: Constants.placeholder, priority: .medium, isCompleted: false, createdAt: Date()))
        controller.delegate = self
        present(controller, animated: true)
    }
}
