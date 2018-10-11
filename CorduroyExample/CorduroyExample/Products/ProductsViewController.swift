import Foundation
import Corduroy

typealias ProductsCoordinator = ProductsViewController

final class ProductsViewController: UIViewController, TabCoordinator, UIStoryboardInitable, NavigationControllerEmbedded {
    static let storyboardName: String = "Main"
    
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator!
    
    // The `presentViewController(context:)` method has a default implementation we can use here that'll present the
    // view controller with the passed-in context.
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
