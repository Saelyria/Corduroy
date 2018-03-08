
import UIKit

/**
 A `UINavigationController` subclass that should be used instead of `UINavigationController` when using Corduroy.
 */
public class CoordinatedNavigationController: UINavigationController {
    /// The navigator the navigation controller reports pop navigations to.
    public var navigator: Navigator?
    
    public convenience init(rootViewController: UIViewController, navigator: Navigator) {
        self.init(rootViewController: rootViewController)
        self.navigator = navigator
    }

    public convenience init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?, navigator: Navigator) {
        self.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.navigator = navigator
    }
    
    @discardableResult
    public override func popViewController(animated: Bool) -> UIViewController? {
        precondition(self.navigator != nil, "CoordinatedNavigationController's navigator property was not set.")
        guard let poppedViewController = super.popViewController(animated: animated) else { return nil }
        self.informNavigatorAboutPoppedViewControllers([poppedViewController])
        
        return poppedViewController
    }
    
    @discardableResult
    public override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        precondition(self.navigator != nil, "CoordinatedNavigationController's navigator property was not set.")
        guard let poppedViewControllers = super.popToViewController(viewController, animated: animated) else { return nil }
        self.informNavigatorAboutPoppedViewControllers(poppedViewControllers)
        
        return poppedViewControllers
    }
    
    @discardableResult
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        precondition(self.navigator != nil, "CoordinatedNavigationController's navigator property was not set.")
        guard let poppedViewControllers = super.popToRootViewController(animated: animated) else { return nil }
        self.informNavigatorAboutPoppedViewControllers(poppedViewControllers)
        
        return poppedViewControllers
    }
    
    private func informNavigatorAboutPoppedViewControllers(_ poppedViewControllers: [UIViewController]) {
        precondition(self.navigator != nil, "CoordinatedNavigationController's navigator property was not set.")

        self.navigator?.navigationControllerDidPopViewControllers(poppedViewControllers)
    }
}
