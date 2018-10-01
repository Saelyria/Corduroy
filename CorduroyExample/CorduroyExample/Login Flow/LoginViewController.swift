import UIKit
import Corduroy

protocol LoginViewControllerCoordinator: AnyCoordinator {
    func loginViewController(_ vc: LoginViewController, didAttemptLoginWithUsername username: String, password: String)
}

final class LoginViewController: UIViewController {
    var coordinator: LoginViewControllerCoordinator?
}
