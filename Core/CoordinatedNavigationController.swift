
import UIKit

public class CoordinatedNavigationController: UINavigationController {
    public var navigator: Navigator!
    
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
        guard let poppedViewController = super.popViewController(animated: animated) else { return nil }
        self.informNavigatorAboutPoppedViewControllers([poppedViewController])
        
        return poppedViewController
    }
    
    @discardableResult
    public override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        guard let poppedViewControllers = super.popToViewController(viewController, animated: animated) else { return nil }
        self.informNavigatorAboutPoppedViewControllers(poppedViewControllers)
        
        return poppedViewControllers
    }
    
    @discardableResult
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        guard let poppedViewControllers = super.popToRootViewController(animated: animated) else { return nil }
        self.informNavigatorAboutPoppedViewControllers(poppedViewControllers)
        
        return poppedViewControllers
    }
    
    private func informNavigatorAboutPoppedViewControllers(_ poppedViewControllers: [UIViewController]) {
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

        // TODO: check if the previous view controller is still managed by the same coordinator, cause we don't want to
        // pop it if it's the same one.
        self.navigator.coordinatedNavControllerDidPopCoordinators(poppedCoordinatorsSet)
    }
}
