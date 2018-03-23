import UIKit
import Corduroy

final class LoggedInPrecondition: RecoveringNavigationPrecondition {
    func evaluate(context: NavigationContext) throws {
        if !AppDelegate.isLoggedIn {
            throw self
        }
    }
    
    func attemptRecovery(context: NavigationContext, completion: @escaping (Bool) -> Void) -> PreconditionRecoveryMethod {
        context.navigator.go(to: LoginFlowCoordinator.self, by: .modallyPresenting, flowCompletion: { error, _ in
            let successfullyRecovered = (error == nil)
            completion(successfullyRecovered)
        })
        return .flowCoordinator
    }
}
