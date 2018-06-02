
import UIKit
import Corduroy

final class SignupFormViewController: UIViewController {
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
