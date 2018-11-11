import Foundation
import RxSwift

protocol UsersListBusinessLogic {
    typealias Event = UsersList.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onViewDidLoadSync(request: Event.ViewDidLoadSync.Request)
    func onReloadUsers(request: Event.ReloadUsers.Request)
    func onLoadMoreUsers(request: Event.LoadMoreUsers.Request)
    func onDidSelectUser(request: Event.DidSelectUser.Request)
    func onDidRemoveUser(request: Event.DidRemoveUser.Request)
}

extension UsersList {
    typealias BusinessLogic = UsersListBusinessLogic
    
    class Interactor {
        
        typealias Event = UsersList.Event
        typealias Model = UsersList.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let usersFetcher: UsersFetcherProtocol
        private let disposeBag: DisposeBag = DisposeBag()

        private var sceneModel: Model.SceneModel
        
        // MARK: -
        
        init(
            presenter: PresentationLogic,
            usersFetcher: UsersFetcherProtocol
            ) {

            self.sceneModel = Model.SceneModel(
                users: [],
                loadingStatus: .loaded,
                loadingMoreStatus: .loaded,
                error: nil
            )
            self.presenter = presenter
            self.usersFetcher = usersFetcher
        }

        // MARK: - Private methods

        private func reloadUsers() {
            self.usersFetcher.reloadUsers()
        }

        private func loadMoreUsers() {
            self.usersFetcher.loadMoreUsers()
        }

        private func observeUsers() {
            self.usersFetcher
                .observeUsers()
                .subscribe(onNext: { [weak self] (users) in
                    self?.sceneModel.users = users
                    self?.usersDidChange()
                })
                .disposed(by: self.disposeBag)
        }

        private func observeLoadingStatus() {
            self.usersFetcher
                .observeLoadingStatus()
                .subscribe(onNext: { [weak self] (loadingStatus) in
                    self?.sceneModel.loadingStatus = loadingStatus
                    self?.loadingStatusDidChange()
                })
                .disposed(by: self.disposeBag)
        }

        private func observeLoadingMoreStatus() {
            self.usersFetcher
                .observeLoadingMoreStatus()
                .subscribe(onNext: { [weak self] (loadingStatus) in
                    self?.sceneModel.loadingMoreStatus = loadingStatus
                    self?.loadingMoreStatusDidChange()
                })
                .disposed(by: self.disposeBag)
        }

        private func observeError() {
            self.usersFetcher
                .observeError()
                .subscribe(onNext: { [weak self] (error) in
                    self?.sceneModel.error = error
                    self?.errorDidChange()
                })
                .disposed(by: self.disposeBag)
        }

        private func usersDidChange() {
            let response = Event.UsersDidChange.Response(users: self.sceneModel.users)
            self.presenter.presentUsersDidChange(response: response)
        }

        private func loadingStatusDidChange() {
            let response = Event.LoadingStatusDidChange.Response(loading: self.sceneModel.loadingStatus == .loading)
            self.presenter.presentLoadingStatusDidChange(response: response)
        }

        private func loadingMoreStatusDidChange() {
            let response = Event.LoadingMoreStatusDidChange.Response(loading: self.sceneModel.loadingMoreStatus == .loading)
            self.presenter.presentLoadingMoreStatusDidChange(response: response)
        }

        private func errorDidChange() {
            let response = Event.ErrorDidChange.Response(title: self.sceneModel.error?.title, message: self.sceneModel.error?.message)
            self.presenter.presentErrorDidChange(response: response)
        }
    }
}

extension UsersList.Interactor: UsersList.BusinessLogic {
    func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.reloadUsers()
        
        self.observeUsers()
        self.observeLoadingStatus()
        self.observeLoadingMoreStatus()
        self.observeError()
    }

    func onViewDidLoadSync(request: Event.ViewDidLoadSync.Request) {
        let response = Event.ViewDidLoadSync.Response(
            hasRefresh: self.usersFetcher.canRefresh,
            hasLoadMore: self.usersFetcher.canLoadMore,
            canRemoveUsers: self.usersFetcher.canRemoveUsers
        )
        self.presenter.presentViewDidLoadSync(response: response)
    }

    func onReloadUsers(request: Event.ReloadUsers.Request) {
        guard self.usersFetcher.canRefresh else { return }
        self.reloadUsers()
    }

    func onLoadMoreUsers(request: Event.LoadMoreUsers.Request) {
        guard self.usersFetcher.canLoadMore else { return }
        self.loadMoreUsers()
    }

    func onDidSelectUser(request: Event.DidSelectUser.Request) {
        let response = request
        self.presenter.presentDidSelectUser(response: response)
    }

    func onDidRemoveUser(request: Event.DidRemoveUser.Request) {
        guard self.usersFetcher.canRemoveUsers else { return }
        self.usersFetcher.removeUserForId(request.id)
    }
}
