
import UIKit
import Corduroy

// Any view controller that is managed by a coordinator (that is not coordinating itself by implementing
// `SelfCoordinating`) must implement `CoordinatorManageable`. The only requirement for this protocol is a `coordinator`
// property of a type the implementing class associates. This can be done by simply declaring the type on the
// `coordinator` property - Swift will infer it from there.
final class SignupFormViewController: UIViewController, CoordinatorManageable {
    // Here we've made the view controller's `ManagingCoordinator` type `SignupFlowCoordinator`. This is fine since this
    // view controller won't be used outside of this specific coordinator's flow, but in general, it's better practice
    // to create a delegate protocol and associate that as the `ManagingCoordinator` that any coordinator can implement
    // and be the coordinator for the view controller.
    var coordinator: SignupFlowCoordinator?
    
    @IBOutlet private var label: UILabel!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    @IBAction func continuePressed() {
        guard let username = self.usernameTextField.text, let password = self.passwordTextField.text, username.count > 5, password.count > 5 else {
            self.label.text = "Create your username and password below.\n They must each be at least five characters long."
            return
        }
        
        self.coordinator?.signupFormViewController(self, didCreateUsername: username, password: password)
    }
}

extension SignupFormViewController: UITextFieldDelegate {    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField === self.passwordTextField {
            self.continuePressed()
        }
        
        return true
    }
}
