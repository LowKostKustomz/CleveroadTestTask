import Foundation

struct UserModel {
    let name: Name
    let phone: String
    let email: String
    let id: Id
    let picture: Picture

    var identifier: String {
        return [self.id.name, self.id.value ?? "", self.name.first, self.name.last, self.phone, self.email].joined()
    }
}

extension UserModel {
    struct Name {
        let first: String
        let last: String
    }
}

extension UserModel {
    struct Id {
        let name: String
        let value: String?
    }
}

extension UserModel {
    struct Picture {
        let large: String
        let medium: String
        let thumbnail: String
    }
}
