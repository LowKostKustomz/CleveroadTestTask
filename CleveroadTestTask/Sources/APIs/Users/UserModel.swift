import Foundation

struct UserModel: Decodable {
    let name: Name
    let phone: String
    let email: String
    private let id: Id
    let picture: Picture

    var identifier: String {
        return [self.id.name, self.id.value ?? "", self.name.first, self.name.last, self.phone, self.email].joined()
    }
}

extension UserModel {
    struct Name: Decodable {
        let first: String
        let last: String
    }
}

extension UserModel {
    struct Id: Decodable {
        let name: String
        let value: String?
    }
}

extension UserModel {
    struct Picture: Decodable {
        let large: String
        let medium: String
        let thumbnail: String
    }
}
