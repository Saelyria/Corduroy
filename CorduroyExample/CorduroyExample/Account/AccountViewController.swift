import Foundation
import Corduroy

typealias AccountCoordinator = AccountViewController

final class AccountViewController: UIViewController, Coordinator, NavigationPreconditionRequiring {
    static let preconditions: [NavigationPrecondition.Type] = [
        LoggedInPrecondition.self
    ]
    
    var navigator: Navigator!
    
    static func create(with: (), navigator: Navigator) -> AccountViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let accountViewController = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
        accountViewController.navigator = navigator
        
        return accountViewController
    }
    
    // The `presentViewController(context:)` method has a default implementation we can use here that'll present the
    // view controller with the passed-in context.
}
