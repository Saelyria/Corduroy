
import UIKit

public extension UIViewController {
    func present(_ toVC: UIViewController, context: Navigator.NavigationContext) {
        guard let presentMethod = context.requestedNavigationMethod as? PresentMethod else { return }
        
        self.present(toVC, by: presentMethod, parameters: context.parameters)
        
    }
    
    func present(_ toVC: UIViewController, by presentMethod: PresentMethod, parameters: NavigationParameters = NavigationParameters()) {
        switch presentMethod {
        case .addingAsChild:
            self.addChildViewController(toVC)
            self.view.addSubview(toVC.view)
            toVC.view.frame = self.view.frame
            toVC.didMove(toParentViewController: self)
        case .modallyPresenting:
            toVC.modalPresentationStyle = parameters.modalPresentationStyle
            toVC.modalTransitionStyle = parameters.modalTransitionStyle
            self.present(toVC, animated: parameters.animateTransition, completion: nil)
        case .pushing:
            self.navigationController?.pushViewController(toVC, animated: parameters.animateTransition)
        }
    }
    
    func dismiss(context: Navigator.NavigationContext) {
        guard let dismissMethod = context.requestedNavigationMethod as? DismissMethod else { return }
        self.dismiss(by: dismissMethod, parameters: context.parameters)
    }
    
    func dismiss(by dismissMethod: DismissMethod, parameters: NavigationParameters = NavigationParameters()) {
        switch dismissMethod {
        case .removingFromParent: break
        case .modallyDismissing:
            self.dismiss(animated: parameters.animateTransition, completion: nil)
        case .popping:
            self.navigationController?.popViewController(animated: parameters.animateTransition)
        }
    }
}
