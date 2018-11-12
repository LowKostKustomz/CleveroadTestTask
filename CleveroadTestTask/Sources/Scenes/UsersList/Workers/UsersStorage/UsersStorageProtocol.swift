import Foundation
import RxSwift

protocol UsersStorageProtocol {
    typealias User = CleveroadTestTask.UserModel

    func clearStorage()
    func update(save: [User], remove: [User])
    func users() -> [User]
    func observeUsers() -> Observable<[User]>
}
