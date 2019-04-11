
import UIKit

public extension AnyCoordinator {
    var navigation: Navigation {
        guard let navigation = self.navigator.navigationStack.filter({ $0.coordinator === self }).first else {
            fatalError("Something got mixed up - coordinator was asked for its navigation, but it wasn't on the stack")
        }
        return navigation
    }
    
    var viewControllers: [UIViewController] {
        guard let navigation: Navigation = self.navigator.navigationStack.filter({ $0.coordinator === self }).first else { return [] }
        return navigation.viewControllersAndPresentMethods.map({ $0.vc })
    }
    
    /**
     Present the given view controller in the style described by the given context.
     - parameter toVC: The view controller to present.
     - parameter context: The context object given to the coordinator by the navigator.
    */
    func present(_ toVC: UIViewController, context: NavigationContext) {
        self.present(toVC, by: context.requestedPresentMethod, parameters: context.parameters)
    }
    
    /**
     Present the given view controller with the given present method and parameters.
     - parameter toVC: The view controller to present.
     - parameter presentMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     */
    func present(_ toVC: UIViewController, by presentMethod: PresentMethod, parameters: Set<NavigationParameter> = .defaults) {
        // if the present method used isn't a navigation push, put the VC in a nav controller if it expects to be
        let vcToPresent: UIViewController = self.embedInNavControllerIfNeeded(toVC, presentMethod: presentMethod)
        
        let context = PresentMethod.PresentContext(
            navigator: self.navigator,
            currentViewController: self.navigator.currentViewController,
            viewControllerToPresent: vcToPresent,
            parameters: parameters)
        guard !(self.navigator.currentViewController == nil && presentMethod.style != .addAsWindowRootViewController) else {
            fatalError("No view controller to present from")
        }
        
        presentMethod.presentHandler(context)
        
        if let presentedNavVC = vcToPresent as? CoordinatedNavigationController {
            presentedNavVC.navigator = self.navigator
            self.navigator.viewControllerDidAppear(presentedNavVC.topViewController!, coordinator: self, presentMethod: presentMethod)
        } else if let presentedNavVC = vcToPresent as? UINavigationController {
            presentedNavVC._navigator = self.navigator
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
    func dismiss(_ vc: UIViewController, parameters: Set<NavigationParameter> = .defaults) {
        let previousCoordinatorIndex: Int = self.navigator.navigationStack.count - 2
        guard let (previousVC, _) = self.navigator.navigationStack[previousCoordinatorIndex].viewControllersAndPresentMethods.last else {
            return
        }
        let currentIndex = self.navigator.navigationStack.count - 1
        guard let (_, presentMethod) = self.navigator.navigationStack[currentIndex].viewControllersAndPresentMethods.last else {
            return
        }
        let context = PresentMethod.DismissContext(
            navigator: self.navigator,
            previousViewController: previousVC,
            viewControllerToDismiss: vc,
            parameters: parameters)
        
        presentMethod.dismissHandler(context)
        
        self.navigator.viewControllerDidDisappear(vc, coordinator: self)
    }
}

internal extension AnyCoordinator {
    func embedInNavControllerIfNeeded(_ vc: UIViewController, presentMethod: PresentMethod) -> UIViewController {
        var vcToPresent: UIViewController = vc
        if let vc = vc as? UIViewController & NavigationControllerEmbedded, presentMethod.style != .navigationControllerPush {
            let navController = vc.createNavigationController()
            if navController.viewControllers.first !== vc {
                navController.viewControllers = [vc]
            }
            vcToPresent = navController
        }
        return vcToPresent
    }
    
    func dismissViewController(params: Set<NavigationParameter>) {
        for (i, viewController) in self.viewControllers.reversed().enumerated() {
            // only animate the last view controller to be dismissed
            var vcParams: Set<NavigationParameter> = params
            if i < self.viewControllers.count - 1 {
                vcParams = .noAnimation
            }
            self.dismiss(viewController, parameters: vcParams)
        }
    }
}
