
import UIKit

protocol NavigationContext {
    var fromViewController: UIViewController { get }
    var fromCoordinator: AnyNavigationCoordinator<Any> { get }
}
