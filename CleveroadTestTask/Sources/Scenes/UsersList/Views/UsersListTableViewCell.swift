import UIKit
import Nuke

enum UsersListTableViewCell {
    struct Model: CellViewModel {
        let id: String
        let name: String
        let phoneNumber: String
        let imageUrl: URL?

        func setup(cell: View) {
            cell.name = self.name
            cell.phone = self.phoneNumber
            cell.iconUrl = imageUrl
        }
    }

    class View: UITableViewCell {

        // MARK: - Private properties

        private let iconView: UIImageView = UIImageView()
        private let iconViewSize: CGFloat = 38
        private let background: UIColor = UIColor.white

        private let nameLabel: UILabel = UILabel()
        private let phoneLabel: UILabel = UILabel()

        // MARK: - Public properties

        var iconUrl: URL? = nil {
            didSet {
                self.iconView.image = nil
                guard let url = self.iconUrl else { return }

                self.iconView.showLoading()
                let imageRequest = ImageRequest(url: url)
                loadImage(
                    with: imageRequest,
                    into: self.iconView,
                    completion: { [weak self] (_, _) in
                        self?.iconView.hideLoading()
                })
            }
        }
        var iconLoading: Bool = false {
            didSet {
                if self.iconLoading {
                    self.iconView.showLoading()
                } else {
                    self.iconView.hideLoading()
                }
            }
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
            self.iconView.layer.masksToBounds = true
        }

        private func setupNameLabel() {
            self.nameLabel.numberOfLines = 0
            self.nameLabel.lineBreakMode = .byWordWrapping
            self.nameLabel.textColor = UIColor.black
            self.nameLabel.textAlignment = .left
            self.nameLabel.font = UIFont.regular.withSize(17)
            self.nameLabel.backgroundColor = self.background
        }

        private func setupPhoneLabel() {
            self.phoneLabel.numberOfLines = 1
            self.phoneLabel.lineBreakMode = .byWordWrapping
            self.phoneLabel.minimumScaleFactor = 0.1
            self.phoneLabel.textColor = UIColor.gray
            self.phoneLabel.textAlignment = .left
            self.phoneLabel.font = UIFont.regular.withSize(15)
            self.phoneLabel.backgroundColor = self.background
        }

        private func layoutViews() {
            self.contentView.addSubview(self.iconView)
            self.contentView.addSubview(self.nameLabel)
            self.contentView.addSubview(self.phoneLabel)

            self.iconView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(15)
                make.top.greaterThanOrEqualToSuperview().inset(11)
                make.bottom.lessThanOrEqualToSuperview().inset(11)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(self.iconViewSize)
            }

            self.nameLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.iconView.snp.right).offset(15)
                make.right.equalToSuperview().inset(15)
                make.top.greaterThanOrEqualToSuperview().inset(10)
            }

            self.phoneLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.iconView.snp.right).offset(15)
                make.right.equalToSuperview().inset(15)
                make.bottom.lessThanOrEqualToSuperview().inset(9)
                make.top.equalTo(self.nameLabel.snp.bottom).offset(3)
            }
        }
    }
}
