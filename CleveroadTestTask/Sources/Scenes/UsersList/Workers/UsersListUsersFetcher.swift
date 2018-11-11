import Foundation
import RxSwift
import RxCocoa

class UsersListUsersFetcher {

    private let usersApi: UsersApi
    private var page: Int = 0
    private let resultsCount: Int = 10

    private let usersBehaviorRelay: BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    private let loadingStatusBehaviorRelay: BehaviorRelay<LoadingStatus> = BehaviorRelay(value: .loaded)
    private let loadingMoreStatusBehaviorRelay: BehaviorRelay<LoadingStatus> = BehaviorRelay(value: .loaded)
    private let errorBehaviorRelay: BehaviorRelay<UsersListUsersFetcherProtocol.Error> = BehaviorRelay(value: nil)

    init(
        usersApi: UsersApi
        ) {

        self.usersApi = usersApi
    }

    func userModelForId(_ id: UsersList.UserIdentifier) -> UserModel? {
        return self.usersBehaviorRelay.value.first(where: { (model) -> Bool in
            return model.identifier == id
        })
    }

    enum LoadUsersResult {
        case success([UserApiModel])
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
                    completion(.success(usersModel.results))
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

    var users: Users { return self.usersBehaviorRelay.value.users }
    var loadingStatus: LoadingStatus { return self.loadingStatusBehaviorRelay.value }
    var loadingMoreStatus: LoadingStatus { return self.loadingMoreStatusBehaviorRelay.value }
    var error: UsersListUsersFetcherProtocol.Error { return self.errorBehaviorRelay.value }

    var canRefresh: Bool { return true }
    var canLoadMore: Bool { return true }

    func observeUsers() -> Observable<Users> {
        return self.usersBehaviorRelay
            .map({ (models) -> Users in
                return models.users
            })
    }
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
            page: 1,
            completion: { [weak self] (result) in
                self?.loadingStatusBehaviorRelay.accept(.loaded)
                switch result {
                case .success(let apiUsers):
                    self?.usersBehaviorRelay.accept(apiUsers.users)
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
                case .success(let apiUsers):
                    let newUsers = (self?.usersBehaviorRelay.value ?? []) + apiUsers.users
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

private extension UserApiModel {
    var user: UserModel {
        return UserModel(
            name: UserModel.Name(
                first: self.name.first,
                last: self.name.last
            ),
            phone: self.phone,
            email: self.email,
            id: UserModel.Id(
                name: self.id.name,
                value: self.id.value
            ),
            picture: UserModel.Picture(
                large: self.picture.large,
                medium: self.picture.medium,
                thumbnail: self.picture.thumbnail
            )
        )
    }
}

private extension Array where Element == UserApiModel {
    var users: [UserModel] {
        return self.map({ (element) -> UserModel in
            return element.user
        })
    }
}

private extension UserModel {
    var user: UsersList.Model.User {
        let name = [self.name.first, self.name.last].joined(separator: " ")

        return UsersList.Model.User(
            name: name,
            phone: self.phone,
            id: self.identifier,
            imageUrl: URL(string: self.picture.thumbnail)
        )
    }
}

private extension Array where Element == UserModel {
    var users: [UsersList.Model.User] {
        return self.map({ (model) -> UsersList.Model.User in
            return model.user
        })
    }
}
