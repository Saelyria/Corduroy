
import UIKit
import Corduroy

// The home screen's navigation is a little more complicated, so we create a coordinator object to handle it. This way,
// the actual `HomeViewController` can just be a controller of its view.
final class HomeCoordinator: Coordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        let homeViewController = HomeViewController()
        homeViewController.coordinator = self
        self.currentViewController = homeViewController
        context.currentViewController.present(homeViewController, context: context)
    }
    
    func buttonPressed() {
        
    }
}
