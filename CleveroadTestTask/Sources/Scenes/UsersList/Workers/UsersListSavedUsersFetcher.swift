import Foundation
import RxSwift
import RxCocoa

class UsersListSavedUsersFetcher {
    private let usersBehaviorRelay: BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    private let loadingStatusBehaviorRelay: BehaviorRelay<LoadingStatus> = BehaviorRelay(value: .loaded)
    private let loadingMoreStatusBehaviorRelay: BehaviorRelay<LoadingStatus> = BehaviorRelay(value: .loaded)
    private let errorBehaviorRelay: BehaviorRelay<UsersListUsersFetcherProtocol.Error> = BehaviorRelay(value: nil)

    private let usersStorage: UsersStorageProtocol
    private let disposeBag: DisposeBag = DisposeBag()

    init(
        usersStorage: UsersStorageProtocol
        ) {

        self.usersStorage = usersStorage
        self.observeStorage()
    }

    func userModelForId(_ id: UsersList.UserIdentifier) -> UserModel? {
        return self.usersBehaviorRelay.value.first(where: { (model) -> Bool in
            return model.identifier == id
        })
    }

    private func observeStorage() {
        self.usersStorage
            .observeUsers()
            .subscribe(onNext: { [weak self] (models) in
                self?.usersBehaviorRelay.accept(models)
            })
            .disposed(by: self.disposeBag)
    }
}

extension UsersListSavedUsersFetcher: UsersListUsersFetcherProtocol {
    var users: Users { return self.usersBehaviorRelay.value.users }
    var loadingStatus: LoadingStatus { return self.loadingStatusBehaviorRelay.value }
    var loadingMoreStatus: LoadingStatus { return self.loadingMoreStatusBehaviorRelay.value }
    var error: UsersListUsersFetcherProtocol.Error { return self.errorBehaviorRelay.value }

    var canRefresh: Bool { return false }
    var canLoadMore: Bool { return false }

    func observeUsers() -> Observable<Users> {
        return self.usersBehaviorRelay
            .map({ (models) -> Users in
                return models.users
            })
    }
    func observeLoadingStatus() -> Observable<LoadingStatus> { return self.loadingStatusBehaviorRelay.asObservable() }
    func observeLoadingMoreStatus() -> Observable<LoadingStatus> { return self.loadingMoreStatusBehaviorRelay.asObservable() }
    func observeError() -> Observable<UsersListUsersFetcherProtocol.Error> { return self.errorBehaviorRelay.asObservable() }

    func reloadUsers() { }
    func loadMoreUsers() { }
}

extension UsersList {
    typealias SavedUsersFetcher = UsersListSavedUsersFetcher
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
