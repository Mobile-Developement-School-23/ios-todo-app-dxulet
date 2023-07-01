//
//  TodoItemCell.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 27.06.2023.
//

import UIKit
import SnapKit

protocol TodoItemCellDelegate: AnyObject {
    func radioButtonTapped(_ cell: TodoItemCell, isSelected: Bool)
}

final class TodoItemCell: UITableViewCell {
    
    // MARK: - Properties
    
    private lazy var radioButton = makeRadioButton()
    private lazy var priorityImageView = UIImageView(image: Images.priorityHigh.image)
    private lazy var todoLabel = makeTodoLabel()
    private lazy var chevronButton = UIImageView(image: Images.chevron.image)
    private lazy var dateImageView = makeDateImageView()
    private lazy var dateLabel = makeDateLabel()
    private lazy var titleStackView = makeTodoLabelStackView()
    private lazy var subtitleStackView = makeDateStackView()
    private lazy var verticalStackView = makeVerticalStackView()
    private lazy var dividerView = DividerView()
    
    weak var delegate: TodoItemCellDelegate?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: AddTodoPresentationModel) {
        
        setupRadioButton(with: viewModel)
        priorityImageView.isHidden = viewModel.priorityIsHidden
        priorityImageView.image = viewModel.priorityImage
        setupText(with: viewModel)
        subtitleStackView.isHidden = viewModel.isHiddenSubtitle
        dateLabel.text = viewModel.subtitle
    }
    
    // MARK: - Lifecycle
    
    private func configureUI() {
        
        [radioButton, verticalStackView, chevronButton, dividerView].forEach { contentView.addSubview($0) }
        selectionStyle = .none
        configureConstraints()
    }
    
    private func configureConstraints() {
        radioButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16) // TODO: Localize
        }
        
        verticalStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16) // TODO: Localize
            make.leading.equalTo(radioButton.snp.trailing).offset(12)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        priorityImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 16, height: 20))
        }
        
        chevronButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16) // TODO: Localize
        }
        
        dividerView.snp.makeConstraints { make in
            make.leading.equalTo(verticalStackView)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    override func prepareForReuse() {
        todoLabel.attributedText = nil
        todoLabel.textColor = Colors.labelPrimary.color
        radioButton.isSelected = false
        radioButton.tintColor = Colors.labelTertiary.color
        radioButton.setImage(Images.radioButtonOff.image, for: .normal)
    }
    
    private func makeVerticalStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, subtitleStackView])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }
    
    private func makeTodoLabelStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [priorityImageView, todoLabel])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }
    
    private func makeDateStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [dateImageView, dateLabel])
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }
    
    private func makeRadioButton() -> UIButton {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = Colors.supportSeparator.color.cgColor
        button.layer.cornerRadius = 12
        button.setImage(Images.radioButtonOn.image, for: .selected)
        button.setImage(Images.radioButtonOff.image, for: .normal)
        button.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        return button
    }
    
    private func makeTodoLabel() -> UILabel {
        let label = UILabel()
        label.font = GlobalConstants.body
        label.textColor = Colors.labelPrimary.color
        label.numberOfLines = 3
        return label
    }
    
    private func makeDateImageView() -> UIImageView {
        let imageView = UIImageView(image: Images.calendar.image)
        imageView.tintColor = Colors.labelTertiary.color
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return imageView
    }
    
    private func makeDateLabel() -> UILabel {
        let label = UILabel()
        label.font = GlobalConstants.subhead
        label.textColor = Colors.labelTertiary.color
        return label
    }
    
    private func setupText(with viewModel: AddTodoPresentationModel) {
        guard viewModel.isCompleted else { return todoLabel.text = viewModel.text }
        guard viewModel.text != nil else { return }
        todoLabel.attributedText = viewModel.title
        todoLabel.textColor = Colors.labelTertiary.color
    }
    
    private func setupRadioButton(with viewModel: AddTodoPresentationModel) {
        if viewModel.isCompleted {
            radioButton.isSelected = true
            return
        } else if viewModel.priority == .high {
            radioButton.setImage(Images.radioButtonHighPriority.image, for: .normal)
        }
        else if let deadline = viewModel.dueDate, deadline < .now {
            setupRadioButtonForDeadlineMiss()
            return
        }
    }
    
    private func setupRadioButtonForDeadlineMiss() {
        radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        radioButton.tintColor = .red
    }
    
    // MARK: - Actions
    
    @objc private func radioButtonTapped() {
        radioButton.isSelected.toggle()
        delegate?.radioButtonTapped(self, isSelected: radioButton.isSelected)
    }
    
}
