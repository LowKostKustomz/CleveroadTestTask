import UIKit
import RxSwift

protocol EditUserProfileDisplayLogic: class {
    typealias Event = EditUserProfile.Event
    
    func displayViewDidLoadSync(viewModel: Event.ViewDidLoadSync.ViewModel)
    func displayEditField(viewModel: Event.EditField.ViewModel)
    func displaySaveUser(viewModel: Event.SaveUser.ViewModel)
}

extension EditUserProfile {
    typealias DisplayLogic = EditUserProfileDisplayLogic
    
    class ViewController: UIViewController {
        
        typealias Event = EditUserProfile.Event
        typealias Model = EditUserProfile.Model
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var routing: Routing?

        // MARK: - Private properties

        private let userImageView: EditUserProfileUserImageView = EditUserProfileUserImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        private let tableView: UITableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)

        private var sections: [[EditUserProfileTitleTextFieldCell.Model]] = []
        private let disposeBag: DisposeBag = DisposeBag()
        
        func inject(interactorDispatch: InteractorDispatch?, routing: Routing?) {
            self.interactorDispatch = interactorDispatch
            self.routing = routing
        }
        
        // MARK: - Overridden
        
        override func viewDidLoad() {
            super.viewDidLoad()

            self.setupView()
            self.setupTableView()
            self.layoutViews()

            self.observeKeyboard()

            let requestSync = Event.ViewDidLoadSync.Request()
            self.interactorDispatch?.sendSyncRequest(requestBlock: { (businessLogic) in
                businessLogic.onViewDidLoadSync(request: requestSync)
            })
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            self.sizeHeaderToFit()
        }

        func sizeHeaderToFit() {
            guard let headerView = tableView.tableHeaderView else { return }

            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()

            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame

            tableView.tableHeaderView = headerView
        }

        private func setupView() {
            self.navigationItem.title = "Edit user profile"

            let saveBarButtonItem = UIBarButtonItem(
                title: "Save",
                style: .done,
                target: nil,
                action: nil
            )
            saveBarButtonItem
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        let request = Event.SaveUser.Request()
                        businessLogic.onSaveUser(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
            self.navigationItem.rightBarButtonItems = [saveBarButtonItem]
        }

        private func setupTableView() {
            self.tableView.register(classes: [EditUserProfileTitleTextFieldCell.Model.self])
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.keyboardDismissMode = .onDrag
        }

        private func setupUserImageView() {

        }

        private func layoutViews() {
            self.view.addSubview(self.tableView)

            self.tableView.tableHeaderView = self.userImageView

            self.tableView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }

        private func observeKeyboard() {
            let observer = KeyboardObserver(self) { [weak self] (attributes) in
                self?.setBottomInsetWithKeyboardAttributes(attributes)
            }
            KeyboardController.shared.add(observer: observer)
        }

        private func setBottomInsetWithKeyboardAttributes(
            _ attributes: KeyboardAttributes?
            ) {

            let keyboardHeight: CGFloat = attributes?.heightInContainerView(self.view, view: self.tableView) ?? 0
            var bottomInset: CGFloat = keyboardHeight
            if attributes?.showingIn(view: self.view) != true {
                if #available(iOS 11, *) {
                    bottomInset += self.view.safeAreaInsets.bottom
                } else {
                    bottomInset += self.bottomLayoutGuide.length
                }
            }
            self.tableView.contentInset.bottom = bottomInset
        }

        private func cellModelForIndexPath(_ indexPath: IndexPath) -> EditUserProfileTitleTextFieldCell.Model {
            return self.sections[indexPath.section][indexPath.row]
        }

        private func focusOnNextCellFromIndexPath(_ indexPath: IndexPath) {
            let nextRowIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            let nextSectionIndexPath = IndexPath(row: 0, section: indexPath.section + 1)
            if self.tableView.cellForRow(at: nextRowIndexPath) != nil {
                self.focusOnCellForIndexPath(nextRowIndexPath)
            } else if self.tableView.cellForRow(at: nextSectionIndexPath) != nil {
                self.focusOnCellForIndexPath(nextSectionIndexPath)
            } else if let cell = self.tableView.cellForRow(at: indexPath) {
                cell.resignFirstResponder()
            }
        }

        private func focusOnCellForIndexPath(_ indexPath: IndexPath) {
            if let cell = self.tableView.cellForRow(at: indexPath) as? EditUserProfileTitleTextFieldCell.View {
                cell.becomeFirstResponder()
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
}

extension EditUserProfile.ViewController: EditUserProfile.DisplayLogic {
    func displayViewDidLoadSync(viewModel: Event.ViewDidLoadSync.ViewModel) {
        self.sections = viewModel.sections
        self.userImageView.imageURL = viewModel.userImageUrl
        self.tableView.reloadData()
    }

    func displayEditField(viewModel: Event.EditField.ViewModel) {
        self.sections = viewModel.sections
    }

    func displaySaveUser(viewModel: Event.SaveUser.ViewModel) {
        switch viewModel {
        case .saved:
            self.routing?.onUserSaved()
        case .failed(let error):
            self.routing?.onSimpleError("Error", error)
        }
    }
}

extension EditUserProfile.ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.focusOnCellForIndexPath(indexPath)
    }
}

extension EditUserProfile.ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.cellModelForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(with: model, for: indexPath)

        if let cell = cell as? EditUserProfileTitleTextFieldCell.View {
            cell.onEdit = { [weak self] (value) in
                let newFieldType: EditUserProfile.Model.FieldType
                switch model.fieldType {
                case .firstName:
                    newFieldType = .firstName(value)
                case .lastName:
                    newFieldType = .lastName(value)
                case .email:
                    newFieldType = .email(value)
                case .phoneNumber:
                    newFieldType = .phoneNumber(value)
                }
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    let request = EditUserProfile.Event.EditField.Request(field: newFieldType)
                    businessLogic.onEditField(request: request)
                })
            }
            cell.onReturn = { [weak self] in
                self?.focusOnNextCellFromIndexPath(indexPath)
            }
        }

        return cell
    }
}
