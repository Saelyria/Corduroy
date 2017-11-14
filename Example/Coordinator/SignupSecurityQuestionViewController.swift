
import UIKit
import Coordinator

final class SignupSecurityQuestionViewController: UIViewController, NavigationCoordinatorManageable {
    struct SetupContext {
        let tempUsername: String
        let tempPassword: String
    }
    typealias SetupContextType = SetupContext
    
    var coordinator: SignupFlowCoordinator!
    
    fileprivate let securityQuestion: String = "What was the name of your first pet?"
    fileprivate let securityAnswerTextField = UITextField()
    
    static func create(with context: SetupContext, coordinator: SignupFlowCoordinator) -> SignupSecurityQuestionViewController {
        let securityQuestionVC = SignupSecurityQuestionViewController()
        securityQuestionVC.coordinator = coordinator
        
        return securityQuestionVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Security Questions"
        self.view.backgroundColor = UIColor.white
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = self.securityQuestion
        self.view.addSubview(label)
        NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: -30).isActive = true
        
        self.securityAnswerTextField.translatesAutoresizingMaskIntoConstraints = false
        self.securityAnswerTextField.placeholder = "Answer here"
        self.view.addSubview(self.securityAnswerTextField)
        NSLayoutConstraint(item: self.securityAnswerTextField, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.securityAnswerTextField, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 40).isActive = true
        
        let continueButton = UIButton(type: .system)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        self.view.addSubview(continueButton)
        NSLayoutConstraint(item: continueButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: continueButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -50).isActive = true
    }
    
    @objc func continuePressed(sender: UIButton) {
        guard let answer = self.securityAnswerTextField.text else {
            return
        }
        
        self.coordinator.securityQuestionViewController(self, didCreateAnswer: answer, forQuestion: self.securityQuestion)
    }
}