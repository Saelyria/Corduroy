
import UIKit
import Corduroy

// The home screen's navigation is a little more complicated, so we create a coordinator object to handle it. This way,
// the actual `HomeViewController` can just be a controller of its view. Our home coordinator is also going to have a
// login precondition on it - this means that, when we try to navigate to it, if we aren't already logged in, it'll
// start the login flow. If we are logged in, it'll go straight to the home page.
final class HomeCoordinator: Coordinator, NavigationPreconditionRequiring {
    static var preconditions: [NavigationPrecondition.Type] = [
        LoggedInPrecondition.self
    ]
    
    var navigator: Navigator!
    
    func presentViewController(context: NavigationContext) {
        let homeViewController = HomeViewController()
        homeViewController.coordinator = self
        self.present(homeViewController, asDescribedBy: context)
    }
    
    func buttonPressed() {
        
    }
}
