import UIKit
import Corduroy

struct NotLoggedInError: Error { }

final class LoggedInPrecondition: FlowRecoveringNavigationPrecondition {
    typealias RecoveringFlowCoordinator = LoginFlowCoordinator
    
    var recoveryCoordinatorPresentMethod: PresentMethod = .modallyPresenting
    
    func evaluate(context: NavigationContext) throws {
        if !AppDelegate.isLoggedIn {
            throw NotLoggedInError()
        }
    }
}
