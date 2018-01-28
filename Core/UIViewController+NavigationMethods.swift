
import UIKit

public extension UIViewController {
    static func present(_ toVC: UIViewController, context: Navigator.NavigationContext) {
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

    static func dismiss(context: Navigator.NavigationContext) {
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
