import Foundation

enum EditUserProfile {
    
    // MARK: - Typealiases
    
    
    // MARK: -
    
    enum Model {}
    enum Event {}
}

// MARK: - Models

extension EditUserProfile.Model {
    struct SceneModel {
        var fields: [FieldType]
    }

    enum FieldValidationError: LocalizedError {
        case invalidFirstName
        case invalidLastName
        case invalidEmail

        var errorDescription: String? {
            switch self {
            case .invalidFirstName:
                return "First name should be 1-30 characters length and cannot contain only whitespaces"
            case .invalidLastName:
                return "Last name should be 1-30 characters length and cannot contain only whitespaces"
            case .invalidEmail:
                return "Invalid email"
            }
        }
    }

    enum FieldType {
        case firstName(String?)
        case lastName(String?)
        case email(String?)
        case phoneNumber(String?)
    }
}

// MARK: - Events

extension EditUserProfile.Event {
    typealias Model = EditUserProfile.Model
    
    // MARK: -

    enum ViewDidLoadSync {
        struct Request { }
        struct Response {
            let fields: [Model.FieldType]
            let userImageUrl: URL?
        }
        struct ViewModel {
            let sections: [[EditUserProfileTitleTextFieldCell.Model]]
            let userImageUrl: URL?
        }
    }

    enum EditField {
        struct Request {
            let field: Model.FieldType
        }
        struct Response {
            let fields: [Model.FieldType]
        }
        struct ViewModel {
            let sections: [[EditUserProfileTitleTextFieldCell.Model]]
        }
    }

    enum SaveUser {
        struct Request { }
        enum Response {
            case saved
            case failed(Error)
        }
        enum ViewModel {
            case saved
            case failed(String)
        }
    }
}

extension EditUserProfile.Model.FieldType {
    typealias SelfType = EditUserProfile.Model.FieldType

    func sameTypeAs(_ another: SelfType) -> Bool {
        switch (self, another) {
        case (.firstName, .firstName),
             (.lastName, .lastName),
             (.email, .email),
             (.phoneNumber, .phoneNumber):
            return true
        default:
            return false
        }
    }
}
