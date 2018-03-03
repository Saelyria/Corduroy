
import UIKit

/**
 A `UINavigationController` subclass that should be used instead of `UINavigationController` when using Corduroy.
 */
public class CoordinatedNavigationController: UINavigationController, CoordinatedViewControllerProtocol {
    /// The coordinator of the navigation controller's top view controller.
    public var baseCoordinator: BaseCoordinator? {
        if let topVC = self.topViewController {
            guard topVC is CoordinatedViewController else {
                fatalError("\(String(describing: type(of: topVC))) does not conform to one of either CoordinatorManageable or SelfCoordinating.")
            }
            let vc = topVC as! CoordinatedViewController
            return vc.baseCoordinator
        }
        return nil
    }
    
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
        let coordinatedViewControllers: [CoordinatedViewController] = poppedViewControllers.filter({ (vc) -> Bool in
            if vc is CoordinatedViewController {
                return true
            } else {
                fatalError("\(String(describing: type(of: vc))) does not conform to one of either CoordinatorManageable or SelfCoordinating.")
            }
        }).map({ $0 as! CoordinatedViewController })
        
        let poppedCoordinators: [BaseCoordinator] = coordinatedViewControllers.map({ (vc) -> BaseCoordinator in
            if let baseCoordinator = vc.baseCoordinator {
                return baseCoordinator
            } else {
                fatalError("A coordinator was not set on \(String(describing: type(of: vc)))")
            }
        })
        
        var poppedCoordinatorsSet: [BaseCoordinator] = []
        poppedCoordinators.forEach { (coordinator) in
            if !poppedCoordinatorsSet.contains(where: { $0 === coordinator }) {
                poppedCoordinatorsSet.append(coordinator)
            }
        }
        poppedCoordinatorsSet.reverse() //reverse to match the coordinator navigation history on Navigator
        
        // Make sure we don't remove the botom-most coordinator of the popped coordinators if it's the coordinator for
        // the new top-most view controller
        if let topVCAfterPop = self.topViewController {
            guard topVCAfterPop is CoordinatedViewController else {
                fatalError("\(String(describing: type(of: topVCAfterPop))) does not conform to one of either CoordinatorManageable or SelfCoordinating.")
            }
            let topVC = topVCAfterPop as! CoordinatedViewController
            if let lastCoordinatorToPop = poppedCoordinatorsSet.first, lastCoordinatorToPop === topVC.baseCoordinator {
                poppedCoordinatorsSet.removeFirst()
            }
        } //self.viewControllers.count-1-poppedViewControllers.count

        self.navigator?.coordinatedNavControllerDidPopCoordinators(poppedCoordinatorsSet)
    }
}
