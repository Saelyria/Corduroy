
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
        switch presentMethod {
        case .modallyPresenting:
            guard let currentVC = self.navigator.currentViewController else { return }
            toVC.modalPresentationStyle = parameters.modalPresentationStyle
            toVC.modalTransitionStyle = parameters.modalTransitionStyle
            currentVC.present(toVC, animated: parameters.animateTransition, completion: nil)
        case .pushing:
            guard let currentVC = self.navigator.currentViewController else { return }
            currentVC.navigationController?.pushViewController(toVC, animated: parameters.animateTransition)
        case .addingAsRoot(let window):
            window.rootViewController = toVC
        case .switchingToTab:
            break
        }
        
        if let presentedNavVC = toVC as? UINavigationController {
            presentedNavVC.delegate = self.navigator.navigationDelegate
//            if !(presentedNavVC is CoordinatedNavigationController) {
//                fatalError("Navigation controllers must subclass CoordinatedNavigationController to be presented by a coordinator.")
//            }
            self.navigator.viewControllerDidAppear(presentedNavVC.topViewController!, coordinator: self, presentMethod: presentMethod)
        } else {
            self.navigator.viewControllerDidAppear(toVC, coordinator: self, presentMethod: presentMethod)
        }
    }
    
    func present<T>(_ toVC: T, by presentMethod: PresentMethod, parameters: NavigationParameters = NavigationParameters())
    where T: NavigationControllerEmbedded {
        var vcToPresent: UIViewController = toVC
        if presentMethod == .pushing {
            guard self.navigator.currentViewController?.navigationController is T.NavigationControllerType else {
                fatalError("Error: the view controller being pushed expects to be in a \(String(describing: T.NavigationControllerType.self)), but the previous view controller's navigation controller is not this type.")
            }
        } else {
            let navController = toVC.createNavigationController()
            if navController.viewControllers.first != toVC {
                navController.viewControllers = [toVC]
            }
            vcToPresent = navController
        }
        self.present(vcToPresent, by: presentMethod, parameters: parameters)
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
