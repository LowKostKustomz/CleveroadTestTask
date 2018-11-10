import Foundation

struct UsersModel: Decodable {
    let results: [UserModel]
    let info: Info
}

extension UsersModel {
    struct Info: Decodable {
        let seed: String
        let results: Int
        let page: Int
        let version: String
    }
}
