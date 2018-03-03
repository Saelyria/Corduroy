
import UIKit

public extension BaseCoordinator {
    /**
     Present the given view controller with the given present method and parameters.
     - parameter toVC: The view controller to present.
     - parameter presentMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     */
    func present(_ toVC: UIViewController, by presentMethod: PresentMethod, parameters: NavigationParameters = NavigationParameters()) {
        let currentVC: UIViewController = self.navigator.currentViewController
        
        switch presentMethod {
        case .addingAsChild:
            currentVC.addChildViewController(toVC)
            currentVC.view.addSubview(toVC.view)
            toVC.view.frame = currentVC.view.frame
            toVC.didMove(toParentViewController: currentVC)
        case .modallyPresenting:
            toVC.modalPresentationStyle = parameters.modalPresentationStyle
            toVC.modalTransitionStyle = parameters.modalTransitionStyle
            currentVC.present(toVC, animated: parameters.animateTransition, completion: nil)
        case .pushing:
            currentVC.navigationController?.pushViewController(toVC, animated: parameters.animateTransition)
        case .addingAsRoot(let window):
            window.rootViewController = toVC
        }
        
        self.navigator.viewControllerDidAppear(toVC, coordinator: self, presentMethod: presentMethod)
    }
    
    /**
     Convenience method to present a view controller with the properties of the given context.
     - parameter toVC: The view controller to present.
     - parameter context: The context that describes the expected navigation, such as the method and the view controller
        to present from.
     */
    func present(_ toVC: UIViewController, asDescribedBy context: NavigationContext) {
        guard let presentMethod = context.requestedPresentMethod else { return }
        self.present(toVC, by: presentMethod, parameters: context.parameters)
    }
    
    /**
     Dismiss the given view controller.
     
     The view controller will be dismissed with the inverse of how it was presented (i.e. if it was presented by
     pushing it in a navigation controller, it will be popped).
     - parameter vc: The view controller to dismiss.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    func dismiss(_ vc: UIViewController, parameters: NavigationParameters = NavigationParameters()) {
        let dismissMethod = self.navigator.navigationStack.last!.viewControllersAndPresentMethods.last!.presentMethod.inverseDismissMethod
        switch dismissMethod {
        case .removingFromParent: break
        case .modallyDismissing:
            vc.dismiss(animated: parameters.animateTransition, completion: nil)
        case .popping:
            vc.navigationController?.popViewController(animated: parameters.animateTransition)
        }
        
        self.navigator.viewControllerDidDisappear(vc, coordinator: self)
    }
}
