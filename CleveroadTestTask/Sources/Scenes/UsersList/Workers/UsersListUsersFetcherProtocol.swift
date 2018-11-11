import Foundation
import RxSwift

enum UsersListUsersFetcherProtocolLoadingStatus {
    case loading
    case loaded
}

struct UsersListUsersFetcherProtocolError {
    let title: String?
    let message: String?
}

protocol UsersListUsersFetcherProtocol {
    typealias User = UsersList.Model.User
    typealias Users = [User]
    typealias LoadingStatus = UsersListUsersFetcherProtocolLoadingStatus
    typealias Error = UsersListUsersFetcherProtocolError?

    var users: Users { get }
    var loadingStatus: LoadingStatus { get }
    var loadingMoreStatus: LoadingStatus { get }
    var error: Error { get }

    var canRefresh: Bool { get }
    var canLoadMore: Bool { get }

    func observeUsers() -> Observable<Users>
    func observeLoadingStatus() -> Observable<LoadingStatus>
    func observeLoadingMoreStatus() -> Observable<LoadingStatus>
    func observeError() -> Observable<Error>

    func reloadUsers()
    func loadMoreUsers()
}

extension UsersList {
    typealias UsersFetcherProtocol = UsersListUsersFetcherProtocol
}
