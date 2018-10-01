import UIKit
import Corduroy

protocol SecurityQuestionsViewControllerCoordinator: AnyCoordinator {
    func securityQuestionsViewController(_ vc: LoginViewController, didAttemptLoginWithQuestion question: String, answer: String)
}

final class SecurityQuestionViewController: UIViewController {
    var coordinator: SecurityQuestionsViewControllerCoordinator?
}
