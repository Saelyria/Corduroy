
import UIKit
import Corduroy

final class SignupSecurityQuestionViewController: UIViewController {    
    var coordinator: SignupFlowCoordinator?
    
    private let securityQuestion: String = "What was the name of your first pet?"
    @IBOutlet private var securityAnswerTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.securityAnswerTextField.delegate = self
    }
    
    @IBAction func continuePressed() {
        guard let answer = self.securityAnswerTextField.text, answer.count > 5 else {
            return
        }
        
        self.coordinator?.securityQuestionViewController(self, didCreateAnswer: answer, forQuestion: self.securityQuestion)
    }
}

extension SignupSecurityQuestionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continuePressed()
        return true
    }
}
