//
//  PriorityView.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 22.06.2023.
//

import UIKit
import TodoModelsYandex

protocol PriorityViewDelegate: AnyObject {
    func priorityChanged(_ priority: Priority)
}

final class PriorityView: UIView {

    // MARK: - Properties

    private enum LocalConstants {
        static let prioritySegmentedControlItems = ["Low", "Medium", "High"]
        static let text = "Важность"
        static let mediumPriorityText = "нет"
        static let segmentedControlWidth: CGFloat = 48
        static let dividerHeight: CGFloat = 0.5
        static let dividerInsetInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
    }

    weak var delegate: PriorityViewDelegate?

    // MARK: - Lifecycle

    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.text = LocalConstants.text
        label.font = GlobalConstants.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var prioritySegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: LocalConstants.prioritySegmentedControlItems)

        let lowPriorityImage = Images.priorityLow.image
        let highPriorityImage = Images.priorityHigh.image

        segmentedControl.setImage(lowPriorityImage.withRenderingMode(.alwaysOriginal), forSegmentAt: 0)
        segmentedControl.setTitle(LocalConstants.mediumPriorityText, forSegmentAt: 1)
        segmentedControl.setImage(highPriorityImage.withRenderingMode(.alwaysOriginal), forSegmentAt: 2)

        segmentedControl.setWidth(LocalConstants.segmentedControlWidth, forSegmentAt: 0)
        segmentedControl.setWidth(LocalConstants.segmentedControlWidth, forSegmentAt: 1)
        segmentedControl.setWidth(LocalConstants.segmentedControlWidth, forSegmentAt: 2)

        let font: [NSAttributedString.Key: Any] = [.font: GlobalConstants.body]
        segmentedControl.setTitleTextAttributes(font, for: .normal)

        segmentedControl.selectedSegmentIndex = 1

        segmentedControl.addTarget(self, action: #selector(segmentedControlTapped(sender:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private lazy var dividerView = DividerView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        addSubviews()
        addConstraints()
    }

    private func addSubviews() {
        addSubview(priorityLabel)
        addSubview(prioritySegmentedControl)
        addSubview(dividerView)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            priorityLabel.topAnchor.constraint(equalTo: topAnchor),
            priorityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: GlobalConstants.padding),
            priorityLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            prioritySegmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -GlobalConstants.padding),

            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LocalConstants.dividerInsetInsets.left),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: LocalConstants.dividerInsetInsets.right),
            dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: LocalConstants.dividerHeight)
        ])
    }

    // MARK: - Selectors

    @objc private func segmentedControlTapped(sender: UISegmentedControl) {
        var priority = Priority.medium

        switch prioritySegmentedControl.selectedSegmentIndex {
        case 0:
            priority = .low
        case 1:
            priority = .medium
        case 2:
            priority = .high
        default:
            priority = .medium
        }

        delegate?.priorityChanged(priority)
    }

    // MARK: - Helpers

    func setPriority(_ priority: Priority) {
        switch priority {
        case .low:
            prioritySegmentedControl.selectedSegmentIndex = 0
        case .medium:
            prioritySegmentedControl.selectedSegmentIndex = 1
        case .high:
            prioritySegmentedControl.selectedSegmentIndex = 2
        }
    }

    func getPriority() -> Priority {
        switch prioritySegmentedControl.selectedSegmentIndex {
        case 0:
            return .low
        case 1:
            return .medium
        case 2:
            return .high
        default:
            return .medium
        }
    }

    func update(with priority: Priority) {
        setPriority(priority)
    }
}
