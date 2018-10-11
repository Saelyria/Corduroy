
import UIKit
import Corduroy

final class SignupCompleteViewController: UIViewController, UIStoryboardInitable, NavigationControllerEmbedded {
    static let storyboardName: String = "Signup"
    
    var coordinator: SignupFlowCoordinator?
    
    @IBAction func continuePressed() {
        self.coordinator?.signupCompleteViewControllerDidPressContinue(self)
    }
}
