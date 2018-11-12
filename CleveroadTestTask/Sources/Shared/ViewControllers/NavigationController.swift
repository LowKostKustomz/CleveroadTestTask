import UIKit

class NavigationController: UINavigationController {

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // This code removes back button title
        self.visibleViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        // This code hides bottom bar if view controllers stack is not empty (view controller to be pushed is not the root view controller)
        viewController.hidesBottomBarWhenPushed = (viewControllers.first != nil)

        super.pushViewController(viewController, animated: animated)
    }
}
