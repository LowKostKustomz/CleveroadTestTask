import UIKit

class UsersListFlowController: BaseFlowController {

    private let tabBarController: UITabBarController = UITabBarController()
    private let usersApi: UsersApi

    init(
        rootNavigation: RootNavigationProtocol,
        usersApi: UsersApi
        ) {

        self.usersApi = usersApi
        super.init(
            rootNavigation: rootNavigation
        )
    }

    func run() {
        let navigationController: UINavigationController = UINavigationController()
        let vc = self.createUsersList()
        navigationController.setViewControllers([vc], animated: false)

        self.tabBarController.setViewControllers([navigationController], animated: false)

        self.rootNavigation.setRootContent(self.tabBarController)
    }

    private func createUsersList() -> UIViewController {
        let controller = UsersList.ViewController()
        controller.tabBarItem = UITabBarItem(title: "Users", image: #imageLiteral(resourceName: "Users icon"), selectedImage: #imageLiteral(resourceName: "Users Active icon"))

        let usersFetcher = UsersList.UsersFetcher(usersApi: self.usersApi)
        let routing = UsersList.Routing(onDidSelectUser: { (userId) in
            // TODO: - Implement
        })

        UsersList.Configurator.configure(
            viewController: controller,
            usersFetcher: usersFetcher,
            routing: routing
        )

        return controller
    }
}
