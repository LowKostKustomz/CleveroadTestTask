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
            usersApi: self.usersApi
        )

        usersListFlowController.run()
        self.currentFlowController = usersListFlowController
    }
}
