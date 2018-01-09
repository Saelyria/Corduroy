
import UIKit
import Coordinator

// The home screen's navigation is a little more complicated, so we create a coordinator object to handle it. This way,
// the actual `HomeViewController` can just be a controller of its view.
final class HomeCoordinator: Coordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    func start(context: Navigator.NavigationContext) {
        let homeViewController = HomeViewController()
        context.currentViewController.present(homeViewController, context: context)
    }
}
