import UIKit

enum UsersListTableViewCell {
    struct Model: CellViewModel {
        let id: String
        let name: String
        let phoneNumber: String
        let image: UIImage?

        func setup(cell: View) {
            cell.name = self.name
            cell.phone = self.phoneNumber
            cell.icon = self.image
        }
    }

    class View: UITableViewCell {

        // MARK: - Private properties

        private let iconView: UIImageView = UIImageView()
        private let iconViewSize: CGFloat = 45
        private let background: UIColor = UIColor.white

        private let nameLabel: UILabel = UILabel()
        private let phoneLabel: UILabel = UILabel()

        // MARK: - Public properties

        var icon: UIImage? {
            get { return self.iconView.image }
            set { self.iconView.image = newValue }
        }

        var name: String {
            get { return self.nameLabel.text ?? "" }
            set { self.nameLabel.text = newValue }
        }

        var phone: String {
            get { return self.phoneLabel.text ?? "" }
            set { self.phoneLabel.text = newValue }
        }

        // MARK: -

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            self.commonInit()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private methods

        private func commonInit() {
            self.setupView()
            self.setupIconView()
            self.setupNameLabel()
            self.setupPhoneLabel()

            self.layoutViews()
        }

        private func setupView() {
            self.accessoryType = .disclosureIndicator
            self.backgroundColor = self.background
            self.separatorInset = UIEdgeInsets.zero
        }

        private func setupIconView() {
            self.iconView.contentMode = .scaleAspectFit
            self.iconView.layer.cornerRadius = self.iconViewSize / 2.0
        }

        private func setupNameLabel() {
            self.nameLabel.numberOfLines = 0
            self.nameLabel.textColor = UIColor.black
            self.nameLabel.textAlignment = .left
            self.nameLabel.backgroundColor = self.background
        }

        private func setupPhoneLabel() {
            self.phoneLabel.numberOfLines = 1
            self.phoneLabel.textColor = UIColor.gray
            self.phoneLabel.textAlignment = .left
            self.phoneLabel.backgroundColor = self.background
        }

        private func layoutViews() {
            self.contentView.addSubview(self.iconView)
            self.contentView.addSubview(self.nameLabel)
            self.contentView.addSubview(self.phoneLabel)

            self.iconView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(15)
                make.top.greaterThanOrEqualToSuperview().inset(15)
                make.bottom.lessThanOrEqualToSuperview().inset(15)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(self.iconViewSize)
            }

            self.nameLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.iconView.snp.right).offset(15)
                make.right.equalToSuperview().inset(15)
                make.top.greaterThanOrEqualToSuperview().inset(12)
            }

            self.phoneLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.iconView.snp.right).offset(15)
                make.right.equalToSuperview().inset(15)
                make.bottom.lessThanOrEqualToSuperview().inset(12)
                make.top.equalTo(self.nameLabel.snp.bottom).offset(12)
            }
        }
    }
}
