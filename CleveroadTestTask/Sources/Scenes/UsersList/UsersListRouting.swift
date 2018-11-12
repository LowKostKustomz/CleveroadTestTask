import Foundation

extension UsersList {
    struct Routing {
        let onDidSelectUser: (_ id: UserIdentifier) -> Void
        let onSimpleError: (_ title: String?, _ message: String?) -> Void
    }
}
