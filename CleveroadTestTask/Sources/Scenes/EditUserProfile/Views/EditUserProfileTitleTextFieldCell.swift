import UIKit
import RxSwift

enum EditUserProfileTitleTextFieldCell {
    struct Model: CellViewModel {

        let title: String
        let value: String?
        let fieldType: EditUserProfile.Model.FieldType
        let keyboardType: UIKeyboardType
        let placeholder: String?

        func setup(cell: View) {
            cell.title = self.title
            cell.value = self.value
            cell.keyboardType = self.keyboardType
            cell.placeholder = self.placeholder
        }
    }

    class View: UITableViewCell {

        typealias OnEditCallback = (_ value: String?) -> Void
        typealias OnReturnCallback = () -> Void

        // MARK: - Private properties

        private let background: UIColor = .white
        private let activeTextFieldTextColor: UIColor = .black
        private let inactiveTextFieldTextColor: UIColor = .gray
        private let disposeBag: DisposeBag = DisposeBag()

        private let textField: UITextField = UITextField()
        private let titleLabel: UILabel = UILabel()

        // MARK: - Public properties

        var title: String {
            get { return self.titleLabel.text ?? "" }
            set { self.titleLabel.text = newValue }
        }

        var value: String? {
            get { return self.textField.text }
            set { self.textField.text = newValue }
        }

        var keyboardType: UIKeyboardType {
            get { return self.textField.keyboardType }
            set { self.textField.keyboardType = newValue }
        }

        var placeholder: String? {
            get { return self.textField.placeholder }
            set { self.textField.placeholder = newValue }
        }

        var onEdit: OnEditCallback? = nil
        var onReturn: OnReturnCallback? = nil

        // MARK: -

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            self.commonInit()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @discardableResult
        override func becomeFirstResponder() -> Bool {
            return self.textField.becomeFirstResponder()
        }

        override var canBecomeFirstResponder: Bool {
            return self.textField.canBecomeFirstResponder
        }

        override var isFirstResponder: Bool {
            return self.textField.isFirstResponder
        }

        @discardableResult
        override func resignFirstResponder() -> Bool {
            return self.textField.resignFirstResponder()
        }

        override var canResignFirstResponder: Bool {
            return self.textField.canResignFirstResponder
        }

        // MARK: - Private methods

        private func commonInit() {
            self.setupView()
            self.setupTitleLabel()
            self.setupTextField()
            self.layoutViews()
        }

        private func setupView() {
            self.selectionStyle = .none
            self.backgroundColor = self.background
            self.separatorInset = .zero
        }

        private func setupTitleLabel() {
            self.titleLabel.numberOfLines = 1
            self.titleLabel.textColor = UIColor.black
            self.titleLabel.textAlignment = .left
            self.titleLabel.font = UIFont.regular.withSize(17)
            self.titleLabel.backgroundColor = self.background
        }

        private func setupTextField() {
            self.textField
                .rx
                .controlEvent(.editingChanged)
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.onEdit?(self?.textField.text)
                })
                .disposed(by: self.disposeBag)

            self.textField
                .rx
                .controlEvent(.editingDidBegin)
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    self?.textField.textColor = self?.activeTextFieldTextColor
                })
                .disposed(by: self.disposeBag)
            self.textField
                .rx
                .controlEvent(.editingDidEnd)
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    self?.textField.textColor = self?.inactiveTextFieldTextColor
                })
                .disposed(by: self.disposeBag)
            self.textField.delegate = self
            self.textField.textAlignment = .right
            self.textField.textColor = self.inactiveTextFieldTextColor
            self.textField.font = UIFont.regular.withSize(17)
            self.textField.backgroundColor = self.background
        }

        private func layoutViews() {
            self.contentView.addSubview(self.titleLabel)
            self.contentView.addSubview(self.textField)

            self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
            self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            self.titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(15)
                make.top.equalToSuperview().inset(12)
                make.bottom.equalToSuperview().inset(12)
            }

            self.textField.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(15)
                make.top.equalToSuperview().inset(12)
                make.bottom.equalToSuperview().inset(12)
                make.left.equalTo(self.titleLabel.snp.right).offset(15)
            }
        }
    }
}

extension EditUserProfileTitleTextFieldCell.View: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onReturn?()
        return true
    }
}
