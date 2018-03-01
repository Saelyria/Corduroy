
import UIKit

public extension UIViewController {
    /**
     Present the given view controller using the present method, current view controller, and parameters described in
     the given navigation context.
     - parameter toVC: The view controller to present.
     - parameter context: The context that describes the expected navigation, such as the method and the view controller
        to present from.
     */
    static func present(_ toVC: UIViewController, asDescribedBy context: NavigationContext) {
        guard let presentMethod = context.requestedPresentMethod else { return }
        let parameters = context.parameters
        
        switch presentMethod {
        case .addingAsChild:
            guard let currentVC = context.currentViewController else { return }
            currentVC.addChildViewController(toVC)
            currentVC.view.addSubview(toVC.view)
            toVC.view.frame = currentVC.view.frame
            toVC.didMove(toParentViewController: currentVC)
        case .modallyPresenting:
            guard let currentVC = context.currentViewController else { return }
            toVC.modalPresentationStyle = parameters.modalPresentationStyle
            toVC.modalTransitionStyle = parameters.modalTransitionStyle
            currentVC.present(toVC, animated: parameters.animateTransition, completion: nil)
        case .pushing:
            guard let currentVC = context.currentViewController else { return }
            if let navController = currentVC as? UINavigationController {
                navController.pushViewController(toVC, animated: parameters.animateTransition)
            } else {
                currentVC.navigationController?.pushViewController(toVC, animated: parameters.animateTransition)
            }
        case .addingAsRoot(let window):
            window.rootViewController = toVC
        }
    }

    /**
     Dismiss the current view controller in the given context as described by the method and parameters in the context.
     - parameter context: The context that describes the expected navigation, such as the method and the view controller
     to dismiss.
     */
    static func dismissCurrentViewController(in context: NavigationContext) {
        guard let dismissMethod = context.requestedDismissMethod else { return }
        let parameters = context.parameters
        
        switch dismissMethod {
        case .removingFromParent: break
        case .modallyDismissing:
            context.currentViewController?.dismiss(animated: parameters.animateTransition, completion: nil)
        case .popping:
            context.currentViewController?.navigationController?.popViewController(animated: parameters.animateTransition)
        }
    }
}
