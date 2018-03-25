
import UIKit
import Corduroy

final class SignupCompleteViewController: UIViewController, CoordinatorManageable {
    var coordinator: SignupFlowCoordinator?
    
    @IBAction func continuePressed() {
        self.coordinator?.signupCompleteViewControllerDidPressContinue(self)
    }
}
