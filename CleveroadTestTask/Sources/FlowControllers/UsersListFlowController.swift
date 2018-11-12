import UIKit

class UsersListFlowController: BaseFlowController {

    private let tabBarNavigationController: NavigationController = NavigationController()
    private let tabBarController: UITabBarController = UITabBarController()
    private let tabBarControllerDelegate: TabBarControllerDelegate = TabBarControllerDelegate()
    private let usersApi: UsersApi
    private let usersStorage: UsersStorageProtocol

    private let usersListTitle = "Users"
    private let savedUsersListTitle = "Saved"

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
        self.tabBarController.delegate = self.tabBarControllerDelegate

        let usersViewController = self.createUsersList()
        let savedUsersViewController = self.createSavedUsersList()

        self.tabBarNavigationController.setViewControllers([self.tabBarController], animated: false)
        let tabBarViewControllers = [usersViewController, savedUsersViewController]

        self.tabBarController.setViewControllers(
            tabBarViewControllers,
            animated: false
        )
        if let first = tabBarViewControllers.first {
            self.tabBarControllerDelegate.updateTabBarNavigationItem(self.tabBarController, fromController: first)
        }

        self.rootNavigation.setRootContent(self.tabBarNavigationController)
    }

    private func createUsersList() -> UIViewController {
        let title = self.usersListTitle

        let controller = UsersList.ViewController()
        controller.tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Users icon"), selectedImage: #imageLiteral(resourceName: "Users Active icon"))
        controller.navigationItem.title = title

        let usersFetcher = UsersList.UsersFetcher(usersApi: self.usersApi)

        let routing = UsersList.Routing(onDidSelectUser: { [weak self] (userId) in
            if let user = usersFetcher.userModelForId(userId) {
                self?.pushEditUserProfile(userModel: user)
            }
            }, onSimpleError: { [weak self] (title, message) in
                self?.showSimpleError(title: title, message: message)
        })

        UsersList.Configurator.configure(
            viewController: controller,
            usersFetcher: usersFetcher,
            routing: routing
        )

        return controller
    }

    private func createSavedUsersList() -> UIViewController {
        let title = savedUsersListTitle

        let controller = UsersList.ViewController()
        controller.tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Saved Users icon"), selectedImage: #imageLiteral(resourceName: "Saved Users Active icon"))
        controller.navigationItem.title = title

        let usersFetcher = UsersList.SavedUsersFetcher(usersStorage: self.usersStorage)

        let routing = UsersList.Routing(onDidSelectUser: { [weak self] (userId) in
            if let user = usersFetcher.userModelForId(userId) {
                self?.pushEditUserProfile(userModel: user)
            }
            }, onSimpleError: { [weak self] (title, message) in
                self?.showSimpleError(title: title, message: message)
        })

        UsersList.Configurator.configure(
            viewController: controller,
            usersFetcher: usersFetcher,
            routing: routing
        )

        return controller
    }

    private func pushEditUserProfile(
        userModel: UserModel
        ) {

        let controller = self.createEditUserProfile(
            userModel: userModel,
            routing: EditUserProfile.Routing(
                onUserSaved: { [weak self] in
                    let optionalIndex = self?.tabBarController.viewControllers?.lastIndex(where: { (controller) -> Bool in
                        return (controller as? UsersList.ViewController)?.navigationItem.title == self?.savedUsersListTitle
                    })
                    if let index = optionalIndex {
                        self?.tabBarController.selectedIndex = index
                        self?.tabBarNavigationController.popViewController(animated: true)
                    }
                }, onSimpleError: { [weak self] (title, message) in
                    self?.showSimpleError(title: title, message: message)
            })
        )
        self.tabBarNavigationController.pushViewController(controller, animated: true)
    }

    private func createEditUserProfile(
        userModel: UserModel,
        routing: EditUserProfile.Routing
        ) -> UIViewController {

        let controller = EditUserProfile.ViewController()

        EditUserProfile.Configurator.configure(
            viewController: controller,
            userModel: userModel,
            usersStorage: self.usersStorage,
            routing: routing
        )

        return controller
    }

    private func showSimpleError(
        title: String?,
        message: String?
        ) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.tabBarNavigationController.present(alert, animated: true, completion: nil)
    }
}

private class TabBarControllerDelegate: NSObject, UITabBarControllerDelegate {
    func updateTabBarNavigationItem(_ tabBarController: UITabBarController, fromController viewController: UIViewController) {
        tabBarController.navigationItem.title = viewController.navigationItem.title
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.updateTabBarNavigationItem(tabBarController, fromController: viewController)
    }
}
