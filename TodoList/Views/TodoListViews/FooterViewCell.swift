//
//  FooterViewCell.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 01.07.2023.
//

import UIKit

protocol FooterViewCellDelegate: AnyObject {
    func footerViewCellDidTapAddNewButton(_ footerViewCell: FooterViewCell)
}

class FooterViewCell: UIView {
    private lazy var addNewButton = makeAddNewButton()
    private lazy var addNewLabel = makeAddNewLabel()
    private var tapGesture: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupTapGesture()
    }
    
    weak var delegate: FooterViewCellDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        setupConstraints()
    }
    
    private func setupConstraints() {
        addSubview(addNewButton)
        addSubview(addNewLabel)
        
        addNewButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17)
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        addNewLabel.snp.makeConstraints { make in
            make.left.equalTo(addNewButton.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(footerViewTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func footerViewTapped() {
        delegate?.footerViewCellDidTapAddNewButton(self)
    }
    
    private func makeAddNewButton() -> UIButton {
        let button = UIButton()
        button.setImage(Images.plusCircle.image, for: .normal)
        return button
    }
    
    private func makeAddNewLabel() -> UILabel {
        let label = UILabel()
        label.text = "Новое"
        label.textColor = Colors.labelTertiary.color
        label.font = GlobalConstants.body
        return label
    }
}
