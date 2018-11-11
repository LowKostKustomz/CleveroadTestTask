import Foundation

enum UsersList {
    
    // MARK: - Typealiases

    typealias UserIdentifier = String
    
    // MARK: -
    
    enum Model {}
    enum Event {}
}

// MARK: - Models

extension UsersList.Model {

    struct SceneModel {
        var users: [User]
        var loadingStatus: UsersListUsersFetcherProtocol.LoadingStatus
        var loadingMoreStatus: UsersListUsersFetcherProtocol.LoadingStatus
        var error: UsersListUsersFetcherProtocol.Error
    }

    struct User {
        let name: String
        let phone: String
        let id: UsersList.UserIdentifier
        let imageUrl: URL?
    }
}

// MARK: - Events

extension UsersList.Event {
    typealias Model = UsersList.Model
    
    // MARK: -
    
    enum ViewDidLoad {
        struct Request { }
    }

    enum ViewDidLoadSync {
        struct Request { }
        struct Response {
            let hasRefresh: Bool
            let hasLoadMore: Bool
        }
        typealias ViewModel = Response
    }

    enum ReloadUsers {
        struct Request { }
    }

    enum LoadMoreUsers {
        struct Request { }
    }

    enum UsersDidChange {
        struct Response {
            let users: [Model.User]
        }
        struct ViewModel {
            let cells: [UsersListTableViewCell.Model]
        }
    }

    enum LoadingStatusDidChange {
        struct Response {
            let loading: Bool
        }
        typealias ViewModel = Response
    }

    enum LoadingMoreStatusDidChange {
        struct Response {
            let loading: Bool
        }
        typealias ViewModel = Response
    }

    enum ErrorDidChange {
        struct Response {
            let title: String?
            let message: String?
        }
        typealias ViewModel = Response
    }

    enum DidSelectUser {
        struct Request {
            let id: UsersList.UserIdentifier
        }
        typealias Response = Request
        typealias ViewModel = Request
    }
}
