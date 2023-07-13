//
//  TodoListController.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 27.06.2023.
//

import UIKit
import TodoModelsYandex

class TodoListController: UIViewController {
    
    private enum Constants {
        static let reuseIdentifier: String = "TodoItemCell"
        static let headerReuseIdentifier: String = "HeaderViewCell"
        static let placeholder: String = "Что надо сделать?"
    }
    
    // MARK: - Properties
    
    private var fileCache = FileCache()
    private let coreDataManager = CoreDataManager(modelName: "FileCacheData")
    private lazy var networkService = NetworkingService(deviceID: device)
    
    private let device: String = {
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        return deviceID
    }()
    
    private var isDirty = true
    
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
    
    private lazy var headerView = makeHeaderView()
    private lazy var tableView = makeTableView()
    private lazy var addButton = makeAddButton()
    private lazy var footerView = makeFooterView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        // fetchData() // CoreData
        fetchSQLData() // SQLite
    }
    
    // MARK: - SQLite
    
    private func fetchSQLData() {
        items = fileCache.loadFromDB()
    }
    
    private func deleteTodoItemSQL(item: TodoItem) {
        fileCache.removeFromDB(item)
        fetchSQLData()
    }
    
    private func addTodoItemSQL(item: TodoItem) {
        fileCache.addToDB(item)
        fetchSQLData()
    }
    
    private func updateTodoItemSQL(item: TodoItem) {
        fileCache.updateDB(item)
        fetchSQLData()
    }
    
    // MARK: - CoreData
    
    private func fetchData() {
        items = coreDataManager.fetch()
    }
    
    private func deleteTodoItem(item: TodoItem) {
        coreDataManager.delete(item)
//        fetchData()
    }
    
    private func addTodoItem(item: TodoItem) {
        coreDataManager.save(item)
//        fetchData()
    }
    
    private func updateTodoItem(item: TodoItem) {
        coreDataManager.update(item)
//        fetchData()
    }
    
    // MARK: - Networking
    
    private func fetchDataNetwork() {
        Task {
            do {
                items = try await networkService.fetchTodos()
                self.isDirty = false
            } catch {
                self.isDirty = true
            }
        }
    }
    
    private func deleteToDoNetwork(item: TodoItem) {
        
        if self.isDirty {
            fetchDataNetwork()
        }
        
        Task(priority: .userInitiated) {
            do {
                _ = try await networkService.deleteTodoItem(item)
                self.isDirty = false
            } catch {
                self.isDirty = true
            }
        }
    }
    
    private func addToDoNetwork(item: TodoItem) {
        
        if self.isDirty {
            fetchDataNetwork()
        }
        
        Task(priority: .userInitiated) {
            do {
                _ = try await networkService.addTodoItem(item)
                self.isDirty = false
            } catch {
                self.isDirty = true
            }
        }
    }
    
    private func changeToDoNetwork(item: TodoItem) {
        
        if self.isDirty {
            fetchDataNetwork()
        }
        
        Task {
            do {
                _ = try await networkService.updateTodoItem(item)
                self.isDirty = false
            } catch {
                self.isDirty = true
            }
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
            make.bottom.equalToSuperview()
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
    
    private func makeTableView() -> ConfiguredTableView {
        let tableView = ConfiguredTableView()
        tableView.register(TodoItemCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 56
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
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
                                           title: "Выполнено") { (_, _, _) in
            var item = self.items[indexPath.row]
            item.isCompleted.toggle()
            self.updateDoneCount()
            self.updateTodoItem(item: item) // CoreData
            self.updateTodoItemSQL(item: item) // SQLite
        }
        
        completed.image = UIImage(systemName: "checkmark.circle.fill")
        completed.backgroundColor = Colors.colorGreen.color
        
        return UISwipeActionsConfiguration(actions: [completed])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive,
                                        title: "Удалить") { (_, _, _) in
            let item = self.items[indexPath.row]
            self.deleteTodoItem(item: item)
            self.deleteTodoItemSQL(item: item)
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
        return filteredItems.count
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
        deleteTodoItem(item: item) // CoreData
        deleteTodoItemSQL(item: item) // SQLite
    }
    
    func addViewControllerDidSave(_: AddTodoController, item: TodoItem) {
        if items.filter({$0.id == item.id}).isEmpty {
            addTodoItem(item: item) // CoreData
            addTodoItemSQL(item: item) // SQLite
        } else {
            updateTodoItem(item: item) // CoreData
            updateTodoItemSQL(item: item) // SQLite
        }
    }
}

extension TodoListController: TodoItemCellDelegate {
    func radioButtonTapped(_ cell: TodoItemCell, isSelected: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var item = items[indexPath.row]
        item.isCompleted = isSelected
        updateTodoItem(item: item) // CoreData
        updateTodoItemSQL(item: item) // SQLite
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
