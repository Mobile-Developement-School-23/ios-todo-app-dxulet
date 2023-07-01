//
//  DeadlineCalenarView.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 23.06.2023.
//

import UIKit

protocol DeadlineCalendarViewDelegate: AnyObject {
    func deadlineSwitcherChanged(_ switcher: UISwitch)
    func deadlineButtonTapped()
}

class DeadlineCalendarView: UIView {

    // MARK: Properties

    private enum LocalConstants {
        static let deadlineText = "Сделать до"
        static let stackViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: -16, right: 0)
        static let trailingInset: CGFloat = -16
        static let dividerHeight: CGFloat = 0.5
        static let dividerInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
    }

    weak var delegate: DeadlineCalendarViewDelegate?

    // MARK: Lifecycle

    private lazy var dividerView = makeDividerView()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = LocalConstants.deadlineText
        label.font = GlobalConstants.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var deadlineSwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(switcherChanged(_:)), for: .valueChanged)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()

    private lazy var deadlineButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = GlobalConstants.footnote
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deadlineButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeDividerView() -> DividerView {
        let view = DividerView()
        view.isHidden = true
        return view
    }

    private func setupSubviews() {
        addSubview(deadlineSwitcher)
        addSubview(stackView)
        stackView.addArrangedSubview(deadlineLabel)
        stackView.addArrangedSubview(deadlineButton)
        addSubview(dividerView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LocalConstants.stackViewInsets.left),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            deadlineSwitcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            deadlineSwitcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: LocalConstants.trailingInset),

            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LocalConstants.dividerInsets.left),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: LocalConstants.dividerInsets.right),
            dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: LocalConstants.dividerHeight)
        ])
    }

    // MARK: - Selectors

    @objc private func switcherChanged(_ switcher: UISwitch) {
        delegate?.deadlineSwitcherChanged(switcher)
    }

    @objc private func deadlineButtonTapped() {
        dividerView.isHidden.toggle()
        delegate?.deadlineButtonTapped()
    }

    // MARK: - Public

    func setDeadlineButtonTitle(_ title: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: title)
        deadlineButton.setTitle(dateString, for: .normal)
    }

    func updateLayoutSwitch(for date: Date?) {
        if let date = date {
            deadlineButton.isHidden = false
            setDeadlineButtonTitle(date)
        } else {
            deadlineButton.isHidden = true
        }
    }

    func update(with date: Date?) {
        if let date {
            deadlineSwitcher.isOn = true
            deadlineButton.isHidden = false
            setDeadlineButtonTitle(date)
        } else {
            deadlineSwitcher.isOn = false
            deadlineButton.isHidden = true
        }
    }

}
