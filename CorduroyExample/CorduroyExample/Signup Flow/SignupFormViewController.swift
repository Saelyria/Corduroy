
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
    
    private let label = UILabel()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Signup"
        self.view.backgroundColor = UIColor.white
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.textAlignment = .center
        self.label.text = "Create your username and password below."
        self.view.addSubview(self.label)
        NSLayoutConstraint(item: self.label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: -30).isActive = true
        
        self.usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.usernameTextField.placeholder = "Username"
        self.view.addSubview(self.usernameTextField)
        NSLayoutConstraint(item: self.usernameTextField, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.usernameTextField, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 40).isActive = true
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.passwordTextField.placeholder = "Password"
        self.view.addSubview(self.passwordTextField)
        NSLayoutConstraint(item: self.passwordTextField, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.passwordTextField, attribute: .top, relatedBy: .equal, toItem: self.usernameTextField, attribute: .bottom, multiplier: 1, constant: 15).isActive = true
        
        let continueButton = UIButton(type: .system)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        self.view.addSubview(continueButton)
        NSLayoutConstraint(item: continueButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: continueButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -50).isActive = true
    }
    
    @objc func continuePressed(sender: UIButton) {
        guard let username = self.usernameTextField.text, let password = self.passwordTextField.text, username.count > 5, password.count > 5 else {
            self.label.text = "Create your username and password below.\n They must each be at least five characters long."
            return
        }
        
        self.coordinator?.signupFormViewController(self, didCreateUsername: username, password: password)
    }
}
