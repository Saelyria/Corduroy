import UIKit
import Corduroy

final class LoginFlowCoordinator: FlowCoordinator {
    var navigator: Navigator!
    
    func presentFirstViewController(context: NavigationContext, flowCompletion: @escaping (Error?, ()?) -> Void) {
        
    }
}

extension LoginFlowCoordinator: LoginViewControllerCoordinator {
    func loginViewController(_ vc: LoginViewController, didAttemptLoginWithUsername username: String, password: String) {
        
    }
}

extension LoginFlowCoordinator: SecurityQuestionsViewControllerCoordinator {
    func securityQuestionsViewController(_ vc: LoginViewController, didAttemptLoginWithQuestion question: String, answer: String) {
        
    }
}
