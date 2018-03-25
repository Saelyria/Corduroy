
import UIKit
import Corduroy

final class WelcomeViewController: UIViewController, CoordinatorManageable {
    var navigator: Navigator!
    
    var coordinator: WelcomeCoordinator?
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var signupButton: UIButton!
    
    @IBAction func signupPressed() {
        self.coordinator?.welcomeViewControllerDidPressSignup(self)
    }
    
    @IBAction func laterPressed() {
        self.coordinator?.welcomeViewControllerDidPressLater(self)
    }
}

