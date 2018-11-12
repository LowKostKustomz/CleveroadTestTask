import UIKit

protocol EditUserProfilePresentationLogic {
    typealias Event = EditUserProfile.Event

    func presentViewDidLoadSync(response: Event.ViewDidLoadSync.Response)
    func presentEditField(response: Event.EditField.Response)
    func presentSaveUser(response: Event.SaveUser.Response)
}

extension EditUserProfile {
    typealias PresentationLogic = EditUserProfilePresentationLogic
    
    class Presenter {
        
        typealias Event = EditUserProfile.Event
        typealias Model = EditUserProfile.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension EditUserProfile.Presenter: EditUserProfile.PresentationLogic {
    func presentViewDidLoadSync(response: Event.ViewDidLoadSync.Response) {
        let fields = response.fields.cellModels
        let viewModel = Event.ViewDidLoadSync.ViewModel(
            sections: [fields],
            userImageUrl: response.userImageUrl
        )
        self.presenterDispatch.displaySync { (displayLogic) in
            displayLogic.displayViewDidLoadSync(viewModel: viewModel)
        }
    }

    func presentEditField(response: Event.EditField.Response) {
        let fields = response.fields.cellModels
        let viewModel = Event.EditField.ViewModel(sections: [fields])
        self.presenterDispatch.display { (displayBlock) in
            displayBlock.displayEditField(viewModel: viewModel)
        }
    }

    func presentSaveUser(response: Event.SaveUser.Response) {
        let viewModel: Event.SaveUser.ViewModel = {
            switch response {
            case .saved:
                return .saved
            case .failed(let error):
                return .failed(error.localizedDescription)
            }
        }()
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displaySaveUser(viewModel: viewModel)
        }
    }
}

private extension Array where Element == EditUserProfile.Model.FieldType {
    var cellModels: [EditUserProfileTitleTextFieldCell.Model] {
        return self.map({ (fieldType) -> EditUserProfileTitleTextFieldCell.Model in
            return fieldType.cellModel
        })
    }
}

private extension EditUserProfile.Model.FieldType {
    var cellModel: EditUserProfileTitleTextFieldCell.Model {
        return EditUserProfileTitleTextFieldCell.Model(
            title: self.title,
            value: self.stringValue,
            fieldType: self,
            keyboardType: self.keyboardType,
            placeholder: self.title
        )
    }
}

private extension EditUserProfile.Model.FieldType {
    var title: String {
        switch self {
        case .firstName:
            return "First name"
        case .lastName:
            return "Last name"
        case .email:
            return "Email"
        case .phoneNumber:
            return "Phone"
        }
    }
}

private extension EditUserProfile.Model.FieldType {
    var stringValue: String? {
        switch self {
        case .firstName(let name):
            return name
        case .lastName(let name):
            return name
        case .email(let email):
            return email
        case .phoneNumber(let phone):
            return phone
        }
    }
}

private extension EditUserProfile.Model.FieldType {
    var keyboardType: UIKeyboardType {
        switch self {
        case .firstName,
             .lastName:
            return .alphabet
        case .email:
            return .emailAddress
        case .phoneNumber:
            return .phonePad
        }
    }
}
