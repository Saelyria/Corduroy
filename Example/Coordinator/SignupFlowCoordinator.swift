
import UIKit
import Coordinator

struct SignupInfo {
    let username: String
    let password: String
    let securityQuestion: String
    let securityAnswer: String
}

final class SignupFlowCoordinator: FlowCoordinator {    
    var currentViewController: UIViewController?
    
    private var completion: ((Error?, SignupInfo?) -> Void)!
    
    private var tempUsername: String?
    private var tempPassword: String?
    private var tempSecurityQuestion: String?
    private var tempSecurityAnswer: String?
    
    func start(with: (), context: Navigator.NavigationContext, completion: @escaping (Error?, SignupInfo?) -> Void) {
        self.completion = completion
        
        let signupVC = SignupFormViewController.create(coordinator: self)
        let navController = UINavigationController(rootViewController: signupVC)
        context.currentViewController.present(navController, animated: true, completion: nil)
    }
    
    func signupFormViewController(_ signupFormVC: SignupFormViewController, didSignUpWithUsername username: String, password: String) {
        self.tempUsername = username
        self.tempPassword = password
        
        let setupContext: SignupSecurityQuestionViewController.SetupModel = (username, password)
        let securityQuesstionVC = SignupSecurityQuestionViewController.create(with: setupContext, coordinator: self)
        signupFormVC.navigationController?.pushViewController(securityQuesstionVC, animated: true)
    }
    
    func securityQuestionViewController(_ securityQuestionVC: SignupSecurityQuestionViewController, didCreateAnswer answer: String, forQuestion question: String) {
        self.tempSecurityAnswer = answer
        self.tempSecurityQuestion = question
        
        guard let username = self.tempUsername, let password = self.tempPassword else {
            return
        }
        let signupInfo = SignupInfo(username: username, password: password, securityQuestion: question, securityAnswer: answer)
        let signupCompleteVC = SignupCompleteViewController.create(with: signupInfo, coordinator: self)
        securityQuestionVC.navigationController?.pushViewController(signupCompleteVC, animated: true)
    }
    
    func signupCompleteViewControllerDidPressContinue(_ signupCompleteVC: SignupCompleteViewController) {
        guard let username = self.tempUsername, let password = self.tempPassword, let securityQuestion = self.tempSecurityQuestion, let securityAnswer = self.tempSecurityAnswer else {
            return
        }
        
        let signupInfo = SignupInfo(username: username, password: password, securityQuestion: securityQuestion, securityAnswer: securityAnswer)
        self.completion(nil, signupInfo)
    }
}
