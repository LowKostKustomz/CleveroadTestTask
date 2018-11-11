import UIKit

class UsersListFlowController: BaseFlowController {

    private let tabBarController: UITabBarController = UITabBarController()
    private let usersApi: UsersApi
    private let usersStorage: UsersStorageProtocol

    init(
        rootNavigation: RootNavigationProtocol,
        usersApi: UsersApi,
        usersStorage: UsersStorageProtocol
        ) {

        self.usersApi = usersApi
        self.usersStorage = usersStorage
        super.init(
            rootNavigation: rootNavigation
        )
    }

    func run() {
        let usersNavigationController: UINavigationController = UINavigationController()
        let usersViewController = self.createUsersList()
        usersNavigationController.setViewControllers([usersViewController], animated: false)

        let savedUsersNavigationController: UINavigationController = UINavigationController()
        let savedUsersViewController = self.createSavedUsersList()
        savedUsersNavigationController.setViewControllers([savedUsersViewController], animated: false)
        
        self.tabBarController.setViewControllers(
            [usersNavigationController, savedUsersNavigationController],
            animated: false
        )

        self.rootNavigation.setRootContent(self.tabBarController)
    }

    private func createUsersList() -> UIViewController {
        let title = "Users"

        let controller = UsersList.ViewController()
        controller.tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Users icon"), selectedImage: #imageLiteral(resourceName: "Users Active icon"))
        controller.navigationItem.title = title

        let usersFetcher = UsersList.UsersFetcher(usersApi: self.usersApi)
        let routing = UsersList.Routing(onDidSelectUser: { [weak self] (userId) in
            // TODO: - Implement
        })

        UsersList.Configurator.configure(
            viewController: controller,
            usersFetcher: usersFetcher,
            routing: routing
        )

        return controller
    }

    private func createSavedUsersList() -> UIViewController {
        let title = "Saved"

        let controller = UsersList.ViewController()
        controller.tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Saved Users icon"), selectedImage: #imageLiteral(resourceName: "Saved Users Active icon"))
        controller.navigationItem.title = title

        let usersFetcher = UsersList.SavedUsersFetcher(usersStorage: self.usersStorage)
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
