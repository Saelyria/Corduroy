
import UIKit

public extension UIViewController {
    func present(_ toVC: UIViewController, context: Navigator.NavigationContext) {
        guard let presentMethod = context.requestedNavigationMethod as? PresentMethod else { return }
        
        self.present(toVC, by: presentMethod, parameters: context.parameters)
        
    }
    
    func present(_ toVC: UIViewController, by presentMethod: PresentMethod, parameters: [NavigationParameterKey: Any] = [:]) {
        let allParameters = NavigationParameterKey.defaultParameters(withOverrides: parameters)
        let animated = allParameters[.animateTransition] as! Bool
        let modalTransitionStyle = allParameters[.modalTransitionStyle] as! UIModalTransitionStyle
        let modalPresentationStyle = allParameters[.modalPresentationStyle] as! UIModalPresentationStyle
        
        switch presentMethod {
        case .addingAsChild:
            self.addChildViewController(toVC)
            self.view.addSubview(toVC.view)
            toVC.view.frame = self.view.frame
            toVC.didMove(toParentViewController: self)
        case .modallyPresenting:
            toVC.modalPresentationStyle = modalPresentationStyle
            toVC.modalTransitionStyle = modalTransitionStyle
            self.present(toVC, animated: animated, completion: nil)
        case .pushing:
            self.navigationController?.pushViewController(toVC, animated: animated)
        }
    }
    
    func dismiss(context: Navigator.NavigationContext) {
        guard let dismissMethod = context.requestedNavigationMethod as? DismissMethod else { return }
        self.dismiss(by: dismissMethod, parameters: context.parameters)
    }
    
    func dismiss(by dismissMethod: DismissMethod, parameters: [NavigationParameterKey: Any] = [:]) {
        let allParameters = NavigationParameterKey.defaultParameters(withOverrides: parameters)
        let animated = allParameters[.animateTransition] as! Bool
        
        switch dismissMethod {
        case .removingFromParent: break
        case .modallyDismissing:
            self.dismiss(animated: animated, completion: nil)
        case .popping:
            self.navigationController?.popViewController(animated: animated)
        }
    }
}
