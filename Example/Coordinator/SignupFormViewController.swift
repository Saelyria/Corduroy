
import UIKit
import Coordinator

final class SignupFormViewController: UIViewController, NavigationCoordinatorManageable {
    private(set) var coordinator: SignupFlowCoordinator!
    
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    
    static func create(with context: EmptyContext, coordinator: SignupFlowCoordinator) -> SignupFormViewController {
        let signupVC = SignupFormViewController()
        signupVC.coordinator = coordinator
        
        return signupVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Signup"
        self.view.backgroundColor = UIColor.white
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Create your username and password below."
        self.view.addSubview(label)
        NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: -30).isActive = true
        
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
        guard let username = self.usernameTextField.text, let password = self.passwordTextField.text else {
            return
        }
        
        self.coordinator.signupFormViewController(self, didSignUpWithUsername: username, password: password)
    }
}
