
import UIKit

public extension BaseCoordinator {
    /**
     Present the given view controller with the given present method and context from the navigator.
     - parameter toVC: The view controller to present.
     - parameter presentMethod: The presentation method to use (e.g. push or modal present).
     - parameter context: The context object given to the coordinator by the navigator.
    */
    func present(_ toVC: UIViewController, by presentMethod: PresentMethod, context: NavigationContext) {
        self.present(toVC, by: presentMethod, parameters: context.parameters)
    }
    
    /**
     Present the given view controller with the given present method and parameters.
     - parameter toVC: The view controller to present.
     - parameter presentMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     */
    func present(_ toVC: UIViewController, by presentMethod: PresentMethod, parameters: NavigationParameters = NavigationParameters()) {
        var vcToPresent: UIViewController = toVC
        if let toVC = toVC as? UIViewController & NavigationControllerEmbedded, presentMethod != .pushing {
            let navController = toVC.createNavigationController()
            if navController.viewControllers.first !== toVC {
                navController.viewControllers = [toVC]
            }
            vcToPresent = navController
        }
        
        switch presentMethod {
        case .modallyPresenting:
            guard let currentVC = self.navigator.currentViewController else { return }
            vcToPresent.modalPresentationStyle = parameters.modalPresentationStyle
            vcToPresent.modalTransitionStyle = parameters.modalTransitionStyle
            currentVC.present(vcToPresent, animated: parameters.animateTransition, completion: nil)
        case .pushing:
            guard let currentVC = self.navigator.currentViewController else { return }
            currentVC.navigationController?.pushViewController(vcToPresent, animated: parameters.animateTransition)
        case .addingAsRoot(let window):
            window.rootViewController = vcToPresent
        case .switchingToTab:
            break //TODO: switch to the tab
        }
        
        if let presentedNavVC = vcToPresent as? UINavigationController {
            if presentedNavVC.delegate !== self.navigator {
                presentedNavVC.delegate = self.navigator.navigationDelegate
            }
            self.navigator.viewControllerDidAppear(presentedNavVC.topViewController!, coordinator: self, presentMethod: presentMethod)
        } else {
            self.navigator.viewControllerDidAppear(vcToPresent, coordinator: self, presentMethod: presentMethod)
        }
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
        case .modallyDismissing:
            vc.dismiss(animated: parameters.animateTransition, completion: nil)
        case .popping:
            vc.navigationController?.popViewController(animated: parameters.animateTransition)
        case .none:
            break
        }
        
        self.navigator.viewControllerDidDisappear(vc, coordinator: self)
    }
}
