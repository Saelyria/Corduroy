
import UIKit

/**
 A `UINavigationController` subclass that should be used instead of `UINavigationController` when using Corduroy if
 the navigator is set to not use method swizzling.
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

internal func swizzle(c: AnyClass, original: Selector, swizzled: Selector) {
    guard let originalMethod = class_getInstanceMethod(c, original),
        let swizzledMethod = class_getInstanceMethod(c, swizzled) else { return }
    
    let didAddMethod = class_addMethod(c, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    
    if didAddMethod {
        class_replaceMethod(c, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UINavigationController {
    private static var navigatorKey: String = "navcontroller_navigator"
    
    internal var _navigator: Navigator? {
        get {
            return objc_getAssociatedObject(self, &UINavigationController.navigatorKey) as? Navigator
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &UINavigationController.navigatorKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    @objc internal func corduroy_popViewController(animated: Bool) -> UIViewController? {
        guard Navigator.useSwizzling == true else { return nil }
        
        let poppedVC = corduroy_popViewController(animated: animated)
        if let poppedVC = poppedVC {
            self._navigator?.navigationControllerDidPopViewControllers([poppedVC])
        }
        return poppedVC
    }
    
    @objc internal func corduroy_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        guard Navigator.useSwizzling == true else { return nil }
        
        let poppedVCs = corduroy_popToViewController(viewController, animated: animated)
        if let poppedVCs = poppedVCs {
            self._navigator?.navigationControllerDidPopViewControllers(poppedVCs)
        }
        return poppedVCs
    }
    
    @objc internal func corduroy_popToRootViewController(animated: Bool) -> [UIViewController]? {
        guard Navigator.useSwizzling == true else { return nil }
        
        let poppedVCs = corduroy_popToRootViewController(animated: animated)
        if let poppedVCs = poppedVCs {
            self._navigator?.navigationControllerDidPopViewControllers(poppedVCs)
        }
        return poppedVCs
    }
}
