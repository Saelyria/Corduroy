import UIKit
import Corduroy

protocol SecurityQuestionsViewControllerCoordinator: BaseCoordinator {
    func securityQuestionsViewController(_ vc: LoginViewController, didAttemptLoginWithQuestion question: String, answer: String)
}

final class SecurityQuestionViewController: UIViewController, CoordinatorManageable {
    var coordinator: SecurityQuestionsViewControllerCoordinator?
}
