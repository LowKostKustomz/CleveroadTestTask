import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var appController: AppController!
    var rootNavigation: RootNavigationViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.rootNavigation = RootNavigationViewController()

        self.appController = AppController(
            rootController: self.rootNavigation
        )
        self.rootNavigation.appController = self.appController

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = self.rootNavigation
        self.window?.makeKeyAndVisible()

        return true
    }
}
