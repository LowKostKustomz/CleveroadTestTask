import Foundation

protocol EditUserProfileBusinessLogic {
    typealias Event = EditUserProfile.Event

    func onViewDidLoadSync(request: Event.ViewDidLoadSync.Request)
    func onEditField(request: Event.EditField.Request)
    func onSaveUser(request: Event.SaveUser.Request)
}

extension EditUserProfile {
    typealias BusinessLogic = EditUserProfileBusinessLogic
    
    class Interactor {
        
        typealias Event = EditUserProfile.Event
        typealias Model = EditUserProfile.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic

        private var sceneModel: Model.SceneModel
        private let userModel: UserModel
        private let usersStorage: UsersStorageProtocol
        
        // MARK: -
        
        init(
            presenter: PresentationLogic,
            userModel: UserModel,
            usersStorage: UsersStorageProtocol
            ) {

            self.presenter = presenter
            self.userModel = userModel
            self.usersStorage = usersStorage
            self.sceneModel = Model.SceneModel(
                fields: [
                    .firstName(self.userModel.name.first),
                    .lastName(self.userModel.name.last),
                    .email(self.userModel.email),
                    .phoneNumber(self.userModel.phone)
                ]
            )
        }

        // MARK: - Private methods

        private func validateFirstName() throws -> String {
            let value = self.sceneModel.fields.compactMap { (fieldType) -> String? in
                switch fieldType {
                case .firstName(let name): return name
                default: return nil
                }
                }.first ?? ""

            let valueLength = value.count
            let valueLengthWithoutWhitespaces = value.replacingOccurrences(of: " ", with: "").count
            guard valueLength >= 1 && valueLength <= 30 && valueLengthWithoutWhitespaces != 0 else {
                throw Model.FieldValidationError.invalidFirstName
            }
            return value
        }

        private func validateLastName() throws -> String {
            let value = self.sceneModel.fields.compactMap { (fieldType) -> String? in
                switch fieldType {
                case .lastName(let name): return name
                default: return nil
                }
                }.first ?? ""

            let valueLength = value.count
            let valueLengthWithoutWhitespaces = value.replacingOccurrences(of: " ", with: "").count
            guard valueLength >= 1 && valueLength <= 30 && valueLengthWithoutWhitespaces != 0 else {
                throw Model.FieldValidationError.invalidLastName
            }
            return value
        }

        private func validateEmail() throws -> String {
            let value = self.sceneModel.fields.compactMap { (fieldType) -> String? in
                switch fieldType {
                case .email(let email): return email
                default: return nil
                }
                }.first ?? ""

            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailValidator = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            guard emailValidator.evaluate(with: value) else {
                throw Model.FieldValidationError.invalidEmail
            }

            return value
        }

        private func validatePhoneNumber() throws -> String {
            let value = self.sceneModel.fields.compactMap { (fieldType) -> String? in
                switch fieldType {
                case .phoneNumber(let number): return number
                default: return nil
                }
                }.first ?? ""

            return value
        }
    }
}

extension EditUserProfile.Interactor: EditUserProfile.BusinessLogic {
    func onViewDidLoadSync(request: Event.ViewDidLoadSync.Request) {
        let response = Event.ViewDidLoadSync.Response(
            fields: self.sceneModel.fields,
            userImageUrl: URL(string: self.userModel.picture.large)
        )
        self.presenter.presentViewDidLoadSync(response: response)
    }

    func onEditField(request: Event.EditField.Request) {
        let optionalIndex = self.sceneModel.fields.lastIndex { (fieldType) -> Bool in
            return fieldType.sameTypeAs(request.field)
        }
        if let index = optionalIndex {
            self.sceneModel.fields[index] = request.field
            let response = Event.EditField.Response(fields: self.sceneModel.fields)
            self.presenter.presentEditField(response: response)
        }
    }

    func onSaveUser(request: Event.SaveUser.Request) {
        let response: Event.SaveUser.Response
        do {
            let firstName = try self.validateFirstName()
            let lastName = try self.validateLastName()
            let email = try self.validateEmail()
            let phone = try self.validatePhoneNumber()

            let newUserModel = UserModel(
                name: UserModel.Name(
                    first: firstName,
                    last: lastName),
                phone: phone,
                email: email,
                id: self.userModel.id,
                picture: self.userModel.picture
            )
            self.usersStorage.update(save: [newUserModel], remove: [self.userModel])
            response = .saved
        } catch (let error) {
            response = .failed(error)
        }
        self.presenter.presentSaveUser(response: response)
    }
}
