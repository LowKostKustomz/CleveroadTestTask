import Foundation
import RealmSwift

class RealmUserModel: Object {

    @objc dynamic var name: RealmUserModelName? = RealmUserModelName()
    @objc dynamic var phone: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var id: RealmUserModelId? = RealmUserModelId()
    @objc dynamic var identifier: String = ""
    @objc dynamic var picture: RealmUserModelPicture? = RealmUserModelPicture()

    static func primaryKeyForUser(_ user: UserModel) -> String {
        return user.identifier
    }

    @objc open override class func primaryKey() -> String? {
        return "identifier"
    }

    static func fromUser(_ user: UserModel) -> RealmUserModel {
        let realmUser = RealmUserModel()
        realmUser.name = RealmUserModelName.fromUserModelName(user.name)
        realmUser.phone = user.phone
        realmUser.email = user.email
        realmUser.id = RealmUserModelId.fromUserModelId(user.id)
        realmUser.identifier = user.identifier
        realmUser.picture = RealmUserModelPicture.fromUserModelPicture(user.picture)
        return realmUser
    }

    func toUser() -> UserModel? {
        guard let name = self.name?.toUserName(),
            let id = self.id?.toUserId(),
            let picture = self.picture?.toUserPicture()
            else {
                return nil
        }

        return UserModel(
            name: name,
            phone: self.phone,
            email: self.email,
            id: id,
            picture: picture
        )
    }
}

class RealmUserModelName: Object {
    @objc dynamic var first: String = ""
    @objc dynamic var last: String = ""

    static func fromUserModelName(_ name: UserModel.Name) -> RealmUserModelName {
        let realmName = RealmUserModelName()
        realmName.first = name.first
        realmName.last = name.last
        return realmName
    }

    func toUserName() -> UserModel.Name {
        return UserModel.Name(
            first: self.first,
            last: self.last
        )
    }
}

class RealmUserModelId: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var value: String? = nil

    static func fromUserModelId(_ id: UserModel.Id) -> RealmUserModelId {
        let realmId = RealmUserModelId()
        realmId.name = id.name
        realmId.value = id.value
        return realmId
    }

    func toUserId() -> UserModel.Id {
        return UserModel.Id(
            name: self.name,
            value: self.value
        )
    }
}

class RealmUserModelPicture: Object {
    @objc dynamic var large: String = ""
    @objc dynamic var medium: String = ""
    @objc dynamic var thumbnail: String = ""

    static func fromUserModelPicture(_ picture: UserModel.Picture) -> RealmUserModelPicture {
        let realmPicture = RealmUserModelPicture()
        realmPicture.large = picture.large
        realmPicture.medium = picture.medium
        realmPicture.thumbnail = picture.thumbnail
        return realmPicture
    }

    func toUserPicture() -> UserModel.Picture {
        return UserModel.Picture(
            large: self.large,
            medium: self.medium,
            thumbnail: self.thumbnail
        )
    }
}
