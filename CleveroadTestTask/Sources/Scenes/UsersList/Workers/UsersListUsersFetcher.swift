import Foundation
import RxSwift
import RxCocoa

class UsersListUsersFetcher {

    private let usersApi: UsersApi
    private var page: Int = 0
    private let resultsCount: Int = 10

    private let usersBehaviorRelay: BehaviorRelay<Users> = BehaviorRelay(value: [])
    private let loadingStatusBehaviorRelay: BehaviorRelay<LoadingStatus> = BehaviorRelay(value: .loaded)
    private let loadingMoreStatusBehaviorRelay: BehaviorRelay<LoadingStatus> = BehaviorRelay(value: .loaded)
    private let errorBehaviorRelay: BehaviorRelay<UsersListUsersFetcherProtocol.Error> = BehaviorRelay(value: nil)

    init(
        usersApi: UsersApi
        ) {

        self.usersApi = usersApi
    }

    enum LoadUsersResult {
        case success(Users)
        case error(UsersListUsersFetcherProtocolError)
    }
    private func loadUsers(
        page: Int,
        completion: @escaping (LoadUsersResult) -> Void
        ) {

        self.usersApi.requestUsers(
            page: page,
            resultsCount: self.resultsCount,
            callback: { [weak self] (result) in
                switch result {
                case .success(let usersModel):
                    self?.page = usersModel.info.page

                    let users: Users = usersModel.results.map({ (model) -> User in
                        let name = [model.name.first, model.name.last].joined(separator: " ")
                        return User(name: name, phone: model.phone, id: model.identifier)
                    })
                    completion(.success(users))
                case .error(let error):
                    let error = UsersListUsersFetcherProtocolError(title: nil, message: error.error)
                    completion(.error(error))
                case .failure:
                    let error = UsersListUsersFetcherProtocolError(title: "Internal server error", message: "I could write about it to developers, but they are ignoring the last issue on GitHub since October, I think it's useless. Try one more time, it works sometimes:)")
                    completion(.error(error))
                }
        })
    }
}

extension UsersListUsersFetcher: UsersListUsersFetcherProtocol {

    var users: Users { return self.usersBehaviorRelay.value }
    var loadingStatus: LoadingStatus { return self.loadingStatusBehaviorRelay.value }
    var loadingMoreStatus: LoadingStatus { return self.loadingMoreStatusBehaviorRelay.value }
    var error: UsersListUsersFetcherProtocol.Error { return self.errorBehaviorRelay.value }

    func observeUsers() -> Observable<Users> { return self.usersBehaviorRelay.asObservable() }
    func observeLoadingStatus() -> Observable<LoadingStatus> { return self.loadingStatusBehaviorRelay.asObservable() }
    func observeLoadingMoreStatus() -> Observable<LoadingStatus> { return self.loadingMoreStatusBehaviorRelay.asObservable() }
    func observeError() -> Observable<UsersListUsersFetcherProtocol.Error> { return self.errorBehaviorRelay.asObservable() }

    func reloadUsers() {
        guard self.loadingStatus != .loading,
            self.loadingMoreStatus != .loading
            else {
                return
        }

        self.loadingStatusBehaviorRelay.accept(.loading)
        self.loadUsers(
            page: 0,
            completion: { [weak self] (result) in
                self?.loadingStatusBehaviorRelay.accept(.loaded)
                switch result {
                case .success(let users):
                    self?.usersBehaviorRelay.accept(users)
                case .error(let error):
                    self?.errorBehaviorRelay.accept(error)
                }
        })
    }

    func loadMoreUsers() {
        guard self.loadingStatus != .loading,
            self.loadingMoreStatus != .loading
            else {
                return
        }

        self.loadingMoreStatusBehaviorRelay.accept(.loading)
        self.loadUsers(
            page: self.page + 1,
            completion: { [weak self] (result) in
                self?.loadingMoreStatusBehaviorRelay.accept(.loaded)
                switch result {
                case .success(let users):
                    let newUsers = (self?.usersBehaviorRelay.value ?? []) + users
                    self?.usersBehaviorRelay.accept(newUsers)
                case .error(let error):
                    self?.errorBehaviorRelay.accept(error)
                }
        })
    }
}

extension UsersList {
    typealias UsersFetcher = UsersListUsersFetcher
}
