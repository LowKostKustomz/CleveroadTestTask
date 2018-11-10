import Foundation

protocol UsersListPresentationLogic {
    typealias Event = UsersList.Event

    func presentUsersDidChange(response: Event.UsersDidChange.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
    func presentLoadingMoreStatusDidChange(response: Event.LoadingMoreStatusDidChange.Response)
    func presentErrorDidChange(response: Event.ErrorDidChange.Response)
    func presentDidSelectUser(response: Event.DidSelectUser.Response)
}

extension UsersList {
    typealias PresentationLogic = UsersListPresentationLogic
    
    class Presenter {
        
        typealias Event = UsersList.Event
        typealias Model = UsersList.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        
        // MARK: -
        
        init(presenterDispatch: PresenterDispatch) {
            self.presenterDispatch = presenterDispatch
        }
    }
}

extension UsersList.Presenter: UsersList.PresentationLogic {
    func presentUsersDidChange(response: Event.UsersDidChange.Response) {
        let cells = response.users.map { (user) -> UsersListTableViewCell.Model in
            return user.cellModel
        }
        let viewModel = Event.UsersDidChange.ViewModel(cells: cells)
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayUsersDidChange(viewModel: viewModel)
        }
    }

    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingStatusDidChage(viewModel: viewModel)
        }
    }

    func presentLoadingMoreStatusDidChange(response: Event.LoadingMoreStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingMoreStatusDidChage(viewModel: viewModel)
        }
    }

    func presentErrorDidChange(response: Event.ErrorDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayErrorDidChange(viewModel: viewModel)
        }
    }

    func presentDidSelectUser(response: Event.DidSelectUser.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayDidSelectUser(viewModel: viewModel)
        }
    }
}

private extension UsersList.Model.User {
    var cellModel: UsersListTableViewCell.Model {
        return UsersListTableViewCell.Model(
            id: self.id,
            name: self.name,
            phoneNumber: self.phone,
            imageUrl: self.imageUrl
        )
    }
}
