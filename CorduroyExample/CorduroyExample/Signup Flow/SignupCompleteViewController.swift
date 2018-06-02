
import UIKit
import Corduroy

final class SignupCompleteViewController: UIViewController {
    var coordinator: SignupFlowCoordinator?
    
    @IBAction func continuePressed() {
        self.coordinator?.signupCompleteViewControllerDidPressContinue(self)
    }
}
