import UIKit
import SwipeCellKit

final class CategoryTableViewCell: SwipeTableViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.label
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.systemBackground
        accessoryType = .disclosureIndicator
        selectionStyle = .default

        contentView.addSubview(titleLabel)
    }

    func configure(with title: String, subtitle: String? = nil, icon: UIImage? = nil) {
        titleLabel.text = title
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
    }
}
