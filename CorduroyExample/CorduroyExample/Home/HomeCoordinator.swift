
import UIKit
import Corduroy

// The home screen's navigation is a little more complicated, so we create a coordinator object to handle it. This way,
// the actual `HomeViewController` can just be a controller of its view.
final class HomeCoordinator: Coordinator {
    var navigator: Navigator!
    
    func presentViewController(context: NavigationContext) {
        let homeViewController = HomeViewController()
        homeViewController.coordinator = self
        self.present(homeViewController, asDescribedBy: context)
    }
    
    func buttonPressed() {
        
    }
}
