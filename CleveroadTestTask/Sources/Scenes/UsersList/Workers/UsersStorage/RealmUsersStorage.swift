import Foundation
import RealmSwift
import RxCocoa
import RxSwift
import RxRealm

final class RealmUsersStorage: UsersStorageProtocol {
    
    private let realmQueue: DispatchQueue = DispatchQueue(
        label: NSStringFromClass(RealmUsersStorage.self).queueLabel,
        qos: .userInteractive,
        attributes: .concurrent
    )
    private let realmFileName: String = NSStringFromClass(RealmUsersStorage.self)
    private let usersObservable: BehaviorRelay<([UsersStorageProtocol.User])> = BehaviorRelay(value: [])

    private var realmRunLoop: CFRunLoop? = nil
    private var configuration: Realm.Configuration {
        var config = Realm.Configuration.defaultConfiguration

        config.fileURL = config.fileURL?.deletingLastPathComponent().appendingPathComponent("\(self.realmFileName).realm")
        config.objectTypes = [
            RealmUserModel.self,
            RealmUserModelName.self,
            RealmUserModelId.self,
            RealmUserModelPicture.self
        ]
        config.deleteRealmIfMigrationNeeded = true
        
        return config
    }
    
    init() {
        realmQueue.async {
            self.realmRunLoop = CFRunLoopGetCurrent()

            CFRunLoopPerformBlock(self.realmRunLoop, CFRunLoopMode.defaultMode.rawValue, {
                if let realm = try? Realm(configuration: self.configuration) {
                    _ = Observable
                        .array(from: realm.objects(RealmUserModel.self))
                        .map { array in
                            return array.map { $0.toUser() }
                        }
                        .subscribe(onNext: { [weak self] (optionalUsers) in
                            let users = optionalUsers.compactMap({ (model) -> UserModel? in
                                return model
                            })
                            self?.usersObservable.accept(users)
                        })
                }
            })

            CFRunLoopRun()
        }
    }
    
    deinit {
        if let runLoop = realmRunLoop {
            CFRunLoopStop(runLoop)
        }
    }
    
    func clearStorage() {
        realmQueue.sync {
            if let realm = try? Realm(configuration: self.configuration) {
                if realm.isInWriteTransaction {
                    realm.cancelWrite()
                }
                try? realm.write {
                    realm.deleteAll()
                }
            }
        }
    }
    
    func update(save: [UsersStorageProtocol.User], remove: [UsersStorageProtocol.User]) {
        realmQueue.sync {
            if let realm = try? Realm(configuration: self.configuration) {
                let sequenceToAdd = save.map { (user) -> RealmUserModel in
                    return RealmUserModel.fromUser(user)
                }
                let sequenceToRemove = remove.compactMap { (user) -> RealmUserModel? in
                    return realm.object(
                        ofType: RealmUserModel.self,
                        forPrimaryKey: RealmUserModel.primaryKeyForUser(user)
                    )
                }

                try? realm.write {
                    realm.delete(sequenceToRemove)
                    realm.add(sequenceToAdd, update: true)
                }
            }
        }
    }

    func users() -> [UsersStorageProtocol.User] {
        return usersObservable.value
    }

    func observeUsers() -> Observable<[UsersStorageProtocol.User]> {
        return usersObservable.asObservable()
    }
}
