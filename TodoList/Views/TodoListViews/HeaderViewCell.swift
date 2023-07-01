//
//  HeaderViewCell.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 01.07.2023.
//

import UIKit
import SnapKit

protocol HeaderViewCellDelegate: AnyObject {
    func showDoneItemsButtonTapped(_: HeaderViewCell, didSelectShowButton isSelected: Bool)
}

class HeaderViewCell: UIView {
    
    // MARK: - Properties
    
    private lazy var doneCountLabel = makeDoneCountLabel()
    private lazy var showDoneItemsButton = makeShowDoneItemsButton()
    
    private var fileCache = FileCache()
    weak var delegate: HeaderViewCellDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(doneCount: Int, showDoneItems: Bool) {
        doneCountLabel.text = "Выполнено - \(doneCount)"
        showDoneItemsButton.setTitle(showDoneItems ? "Скрыть" : "Показать", for: .normal)
    }
    
    func updateDoneCount(_ count: Int) {
        doneCountLabel.text = "Выполнено - \(count)"
    }
    
    
    // MARK: - Lifecycle
    
    private func configureUI() {
        backgroundColor = Colors.backPrimary.color
        [doneCountLabel, showDoneItemsButton].forEach { addSubview($0) }
        configureConstraints()
    }
    
    private func configureConstraints() {
        
        doneCountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(32)
            make.bottom.equalToSuperview().offset(-12)
        }
        showDoneItemsButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.greaterThanOrEqualTo(doneCountLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-32)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: - Private functions
    
    private func makeDoneCountLabel() -> UILabel {
        let label = UILabel()
        label.font = GlobalConstants.subhead
        label.text = "Выполнено - \(fileCache.items.values.filter({ $0.isCompleted }).count)"
        label.textColor = Colors.labelTertiary.color
        return label
    }
    
    private func makeShowDoneItemsButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(Colors.colorBlue.color, for: .normal)
        button.titleLabel?.font = GlobalConstants.subheadBold
        button.setTitle("Показать", for: .normal) // TODO: Localize
        button.setTitle("Скрыть", for: .selected) // TODO: Localize
        button.isSelected = true
        button.addTarget(self, action: #selector(showDoneItemsButtonTapped), for: .touchUpInside)
        return button
    }
    
    // MARK: - Selectors
    
    @objc private func showDoneItemsButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        delegate?.showDoneItemsButtonTapped(self, didSelectShowButton: sender.isSelected)
    }
}
