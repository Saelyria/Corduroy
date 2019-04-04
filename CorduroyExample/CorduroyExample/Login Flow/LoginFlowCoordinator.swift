import UIKit
import Corduroy

final class LoginFlowCoordinator: FlowCoordinator {
    var navigator: Navigator!
    
    private var expectedUsername: String!
    private var expectedPassword: String!
    private var securityQuestion: String!
    private var expectedSecurityAnswer: String!
    
    static func create(with: (), navigator: Navigator) -> LoginFlowCoordinator {
        let loginFlowCoordinator = LoginFlowCoordinator()
        
        // gross user defaults stuff cause demo
        loginFlowCoordinator.expectedUsername = UserDefaults.standard.string(forKey: "username")
        loginFlowCoordinator.expectedPassword = UserDefaults.standard.string(forKey: "password")
        loginFlowCoordinator.securityQuestion = UserDefaults.standard.string(forKey: "security-question")
        loginFlowCoordinator.expectedSecurityAnswer = UserDefaults.standard.string(forKey: "security-answer")
        
        return loginFlowCoordinator
    }
    
    func start(context: NavigationContext, flowCompletion: @escaping (Error?, ()?) -> Void) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        self.present(loginViewController, context: context)
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
