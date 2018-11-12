import Foundation

class AppController {

    private let rootController: RootNavigationProtocol
    private var currentFlowController: FlowControllerProtocol?

    private lazy var usersApi: UsersApi = {
        return UsersApi(
            baseUrl: URL(string: "https://randomuser.me")!,
            network: NetworkAdapter()
        )
    }()
    private lazy var usersStorage: UsersStorageProtocol = {
        return RealmUsersStorage()
    }()

    init(
        rootController: RootNavigationProtocol
        ) {

        self.rootController = rootController
    }

    func onRootWillAppear() {
        self.runLaunchFlowController()
    }

    // MARK: - Private methods

    private func runLaunchFlowController() {
        let usersListFlowController = UsersListFlowController(
            rootNavigation: self.rootController,
            usersApi: self.usersApi,
            usersStorage: self.usersStorage
        )

        usersListFlowController.run()
        self.currentFlowController = usersListFlowController
    }
}
