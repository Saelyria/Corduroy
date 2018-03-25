import Foundation
import Corduroy

/*
 Here's a demo of a self-coordinating view controller. This can be used anywhere where your view controllers are pretty
 light and reduce bloat. Starting off a view controller as self-coordinating is good to get it off the ground and reduce
 boilerplate - plus, if this view controller were to become more complicated over the course of development, it wouldn't
 be hard to decide later to split it into a coordinator and view controller pair to avoid the 'Massive View Controller'
 problem.
 
 Another little tidbit - while obviously not required, here I've added a typealias of AccountViewController to
 AccountCoordinator. This hides implementation details for the 'welcome' page (i.e. people that want to navigate to
 'welcome' still think to navigate to a coordinator; don't need to know that it's in fact a view controller that's self-
 coordinating). You also wouldn't need to update any code outside of the account VC / coordinator if you did decide to
 split up AccountViewController.
 */
typealias AccountCoordinator = AccountViewController

final class AccountViewController: UIViewController, SelfCoordinating, NavigationPreconditionRequiring {
    static let preconditions: [NavigationPrecondition.Type] = [
        LoggedInPrecondition.self
    ]
    
    var navigator: Navigator!
    
    // Normally, we wouldn't need to implement this `Coordinator` method - a default value that creates the coordinator
    // and sets its 'navigator' is provided. However, because we want to instantiate our view controller from a
    // storyboard, we need to implement it.
    static func create(with: (), navigator: Navigator) -> AccountViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let accountViewController = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
        accountViewController.navigator = navigator
        
        return accountViewController
    }
    
    // The `presentViewController(context:)` method has a default implementation we can use here that'll present the
    // view controller with the passed-in context.
}
