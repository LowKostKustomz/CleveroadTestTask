import UIKit
import SnapKit
import RxSwift

protocol UsersListDisplayLogic: class {
    typealias Event = UsersList.Event

    func displayViewDidLoadSync(viewModel: Event.ViewDidLoadSync.ViewModel)
    func displayUsersDidChange(viewModel: Event.UsersDidChange.ViewModel)
    func displayLoadingStatusDidChage(viewModel: Event.LoadingStatusDidChange.ViewModel)
    func displayLoadingMoreStatusDidChage(viewModel: Event.LoadingMoreStatusDidChange.ViewModel)
    func displayErrorDidChange(viewModel: Event.ErrorDidChange.ViewModel)
    func displayDidSelectUser(viewModel: Event.DidSelectUser.ViewModel)
}

extension UsersList {
    typealias DisplayLogic = UsersListDisplayLogic
    
    class ViewController: UIViewController {
        
        typealias Event = UsersList.Event
        typealias Model = UsersList.Model
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var routing: Routing?

        // MARK: -

        private var sections: [[UsersListTableViewCell.Model]] = []
        private var oldPanTranslation: CGFloat = 0
        private var canRemoveUsers: Bool = false
        private let disposeBag: DisposeBag = DisposeBag()

        private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        private let refreshControl: UIRefreshControl = UIRefreshControl(frame: .zero)
        private let loadMoreActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
        private let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 0))
        
        func inject(interactorDispatch: InteractorDispatch?, routing: Routing?) {
            self.interactorDispatch = interactorDispatch
            self.routing = routing
        }
        
        // MARK: - Overridden
        
        override func viewDidLoad() {
            super.viewDidLoad()

            self.setupView()
            self.setupRefreshControl()
            self.setupLoadMoreActivityIndicator()
            self.setupTableView()
            self.layoutViews()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }

            let requestSync = Event.ViewDidLoadSync.Request()
            self.interactorDispatch?.sendSyncRequest(requestBlock: { (businessLogic) in
                businessLogic.onViewDidLoadSync(request: requestSync)
            })
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            self.smoothlyDeselectRows()
        }

        // MARK: - Private methods

        private func setupView() { }

        private func setupRefreshControl() {
            self.refreshControl
                .rx
                .controlEvent(.valueChanged)
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        let request = Event.ReloadUsers.Request()
                        businessLogic.onReloadUsers(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
        }

        private func setupLoadMoreActivityIndicator() {
            self.loadMoreActivityIndicator.startAnimating()
        }

        private func setupTableView() {
            self.tableView.register(classes: [UsersListTableViewCell.Model.self])
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }

        private func layoutViews() {
            self.view.addSubview(self.tableView)

            self.tableView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            self.loadMoreActivityIndicator.frame.size.height = 32
        }

        // Helpers

        private func cellModelForIndexPath(_ indexPath: IndexPath) -> UsersListTableViewCell.Model {
            return self.sections[indexPath.section][indexPath.row]
        }

        // Refresh

        private func showRefresh(animated: Bool) {
            self.revealRefreshControlIfNeeded(animated: animated)
            self.beginRefreshing()
        }

        private func beginRefreshing() {
            self.refreshControl.beginRefreshing()
        }

        private func hideRefresh(animated: Bool) {
            guard self.refreshControl.isRefreshing else {
                return
            }
            self.endRefreshing()
            self.hideRefreshControlIfNeeded(animated: animated)
        }

        private func endRefreshing() {
            self.refreshControl.endRefreshing()
        }

        private func revealRefreshControlIfNeeded(animated: Bool) {
            if self.tableView.contentOffset.y <= 0 {
                self.revealRefreshControl(animated: animated)
            }
        }

        private func revealRefreshControl(animated: Bool) {
            self.setOffset(withRefreshControl: true, animated: animated)
        }

        private func hideRefreshControlIfNeeded(animated: Bool) {
            if self.tableView.contentOffset.y <= 0 {
                self.hideRefreshControl(animated: animated)
            }
        }

        private func hideRefreshControl(animated: Bool) {
            self.setOffset(withRefreshControl: false, animated: animated)
        }

        private func setOffset(withRefreshControl: Bool, animated: Bool) {
            guard !self.tableView.isDecelerating,
                !self.tableView.isTracking,
                !self.tableView.isDragging
                else {
                    return
            }

            var oldOffset = self.tableView.contentOffset
            if withRefreshControl {
                oldOffset.y -= self.refreshControl.frame.height
            }
            self.tableView.setContentOffset(oldOffset, animated: animated)
        }

        // Load more

        private func showLoadMoreIndicator() {
            self.tableView.tableFooterView = self.loadMoreActivityIndicator
        }

        private func hideLoadMoreIndicator() {
            self.tableView.tableFooterView = self.tableFooterView
        }

        //

        private func smoothlyDeselectRows() {
            guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows
                else {
                    return
            }

            if let coordinator = transitionCoordinator {
                coordinator.animate(alongsideTransition: { (context) in
                    selectedIndexPaths.forEach { (indexPath) in
                        self.tableView.deselectRow(at: indexPath, animated: context.isAnimated)
                    }
                }, completion: { (context) in
                    if context.isCancelled {
                        selectedIndexPaths.forEach { (indexPath) in
                            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                    }
                })
            }
            else {
                selectedIndexPaths.forEach { (indexPath) in
                    self.tableView.deselectRow(at: indexPath, animated: false)
                }
            }
        }
    }
}

extension UsersList.ViewController: UsersList.DisplayLogic {
    func displayViewDidLoadSync(viewModel: Event.ViewDidLoadSync.ViewModel) {
        if viewModel.hasRefresh {
            self.tableView.refreshControl = self.refreshControl
        }

        if viewModel.hasLoadMore {
            self.tableView.tableFooterView = self.loadMoreActivityIndicator
            self.tableView.tableFooterView?.isHidden = true
        } else {
            self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 0))
        }

        self.canRemoveUsers = viewModel.canRemoveUsers
    }

    func displayUsersDidChange(viewModel: Event.UsersDidChange.ViewModel) {
        self.sections = [viewModel.cells]
        self.tableView.reloadData()
    }

    func displayLoadingStatusDidChage(viewModel: Event.LoadingStatusDidChange.ViewModel) {
        if viewModel.loading {
            self.showRefresh(animated: true)
        } else {
            self.hideRefresh(animated: true)
        }
    }

    func displayLoadingMoreStatusDidChage(viewModel: Event.LoadingMoreStatusDidChange.ViewModel) {
        if viewModel.loading {
            self.showLoadMoreIndicator()
        } else {
            self.hideLoadMoreIndicator()
        }
    }

    func displayErrorDidChange(viewModel: Event.ErrorDidChange.ViewModel) {
        guard viewModel.message != nil || viewModel.title != nil else { return }
        self.routing?.onSimpleError(viewModel.title ?? "Error", viewModel.message)
    }

    func displayDidSelectUser(viewModel: Event.DidSelectUser.ViewModel) {
        self.routing?.onDidSelectUser(viewModel.id)
    }
}

extension UsersList.ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.cellModelForIndexPath(indexPath)
        self.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
            let request = Event.DidSelectUser.Request(id: model.id)
            businessLogic.onDidSelectUser(request: request)
        })
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions: [UITableViewRowAction] = []

        if self.canRemoveUsers {
            actions.append(UITableViewRowAction(
                style: .destructive,
                title: "Remove",
                handler: { [weak self] (action, indexPath) in
                    if let model = self?.cellModelForIndexPath(indexPath) {
                        let request = Event.DidRemoveUser.Request(id: model.id)
                        self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                            businessLogic.onDidRemoveUser(request: request)
                        })
                    }
                }
            ))
        }

        return actions
    }
}

extension UsersList.ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.cellModelForIndexPath(indexPath)
        return tableView.dequeueReusableCell(with: model, for: indexPath)
    }
}

extension UsersList.ViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.oldPanTranslation = 0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: self.view).y
        let delta = translation - self.oldPanTranslation
        self.oldPanTranslation = translation
        let currentOffset = scrollView.contentOffset.y
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        if delta < 0,
            currentOffset >= absoluteBottom,
            deltaOffset <= 0 {

            self.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                let request = UsersList.Event.LoadMoreUsers.Request()
                businessLogic.onLoadMoreUsers(request: request)
            })
        }
    }
}
