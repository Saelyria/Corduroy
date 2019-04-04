
import UIKit
import Corduroy

struct SignupInfo {
    let username: String
    let password: String
    let securityQuestion: String
    let securityAnswer: String
}

// 'Flows' are best described as a series of view controllers used to complete a specific task. In this case, we're
// doing a sign up flow. Flow coordinators are the brains behind a flow - they use one or more view controllers to
// perform specific parts of the flow while still ultimately being the single navigation item as far as the rest of the
// app is concerned. In this case, we've split signup between three view controllers.
final class SignupFlowCoordinator: FlowCoordinator {
    var navigator: Navigator!
    
    private var completion: ((Error?, SignupInfo?) -> Void)!
    
    private var tempUsername: String?
    private var tempPassword: String?
    private var tempSecurityQuestion: String?
    private var tempSecurityAnswer: String?

    func start(context: NavigationContext, flowCompletion: @escaping (Error?, SignupInfo?) -> Void) {
        self.completion = flowCompletion
        
        let signupVC = SignupFormViewController.createFromStoryboard()
        signupVC.coordinator = self
        self.present(signupVC, context: context)
    }
    
    // When the username/password creation view controller finishes, push the security question view controller.
    func signupFormViewController(_ signupFormVC: SignupFormViewController, didCreateUsername username: String, password: String) {
        self.tempUsername = username
        self.tempPassword = password
        
        let securityQuesstionVC = SignupSecurityQuestionViewController.createFromStoryboard()
        securityQuesstionVC.coordinator = self
        self.present(securityQuesstionVC, by: .pushing)
    }
    
    // When the security question view controller finishes, push the completed view controller.
    func securityQuestionViewController(_ securityQuestionVC: SignupSecurityQuestionViewController, didCreateAnswer answer: String, forQuestion question: String) {
        self.tempSecurityAnswer = answer
        self.tempSecurityQuestion = question
        
        let signupCompleteVC = SignupCompleteViewController.createFromStoryboard()
        signupCompleteVC.coordinator = self
        self.present(signupCompleteVC, by: .pushing)
    }
    
    // When the user presses 'Continue' on the completed view controller, call the flow coordinator's 'completion'
    // closure. This leaves it up to whoever started this flow to decide what to do with the information.
    func signupCompleteViewControllerDidPressContinue(_ signupCompleteVC: SignupCompleteViewController) {
        guard let username = self.tempUsername,
            let password = self.tempPassword,
            let securityQuestion = self.tempSecurityQuestion,
            let securityAnswer = self.tempSecurityAnswer else {
                return
        }
        
        let signupInfo = SignupInfo(username: username, password: password, securityQuestion: securityQuestion, securityAnswer: securityAnswer)
        
        // save to user defaults for the sake of the demo
        UserDefaults.standard.set(signupInfo.username, forKey: "username")
        UserDefaults.standard.set(signupInfo.password, forKey: "password")
        UserDefaults.standard.set(signupInfo.securityQuestion, forKey: "security-question")
        UserDefaults.standard.set(signupInfo.securityAnswer, forKey: "security-answer")

        self.completion(nil, signupInfo)
    }
}
