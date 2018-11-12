import Foundation

protocol FlowControllerProtocol { }

class BaseFlowController: FlowControllerProtocol {

    let rootNavigation: RootNavigationProtocol

    init(
        rootNavigation: RootNavigationProtocol
        ) {

        self.rootNavigation = rootNavigation
    }
}
