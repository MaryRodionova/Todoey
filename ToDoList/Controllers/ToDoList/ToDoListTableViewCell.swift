import UIKit
import SwipeCellKit

final class ToDoListTableViewCell: SwipeTableViewCell {

    private enum Layout {
        static let cellVerticalPadding: CGFloat = 4
        static let cellHorizontalPadding: CGFloat = 0
        static let containerCornerRadius: CGFloat = 8
        static let containerTopPadding: CGFloat = 8
        static let containerBottomPadding: CGFloat = 8
        static let containerHorizontalPadding: CGFloat = 16
        static let titleBottomSpacing: CGFloat = 2
        static let shadowOpacity: Float = 0.1
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let shadowRadius: CGFloat = 3
    }

    static let reuseId = "PrototypeCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String) {
        titleLabel.text = title
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .default
    }
}

// MARKL - Setup Constraints

private extension ToDoListTableViewCell {

    func addSubviews() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cellVerticalPadding),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cellHorizontalPadding),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.cellHorizontalPadding),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cellVerticalPadding),

                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.containerTopPadding),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.containerHorizontalPadding),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.containerHorizontalPadding),
                titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Layout.containerBottomPadding)
                
            ]
        )
    }
}

