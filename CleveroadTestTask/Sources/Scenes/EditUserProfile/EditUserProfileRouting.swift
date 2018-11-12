import Foundation

extension EditUserProfile {
    struct Routing {
        let onUserSaved: () -> Void
        let onSimpleError: (_ title: String?, _ message: String?) -> Void
    }
}
