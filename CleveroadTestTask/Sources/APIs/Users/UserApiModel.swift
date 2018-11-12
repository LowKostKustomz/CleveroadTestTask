import Foundation

struct UserApiModel: Decodable {
    let name: Name
    let phone: String
    let email: String
    let id: Id
    let picture: Picture
}

extension UserApiModel {
    struct Name: Decodable {
        let first: String
        let last: String
    }
}

extension UserApiModel {
    struct Id: Decodable {
        let name: String
        let value: String?
    }
}

extension UserApiModel {
    struct Picture: Decodable {
        let large: String
        let medium: String
        let thumbnail: String
    }
}
