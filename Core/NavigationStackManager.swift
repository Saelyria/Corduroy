import UIKit

/**
 An internal model type that holds the information of a navigation operation that is stored on a navigator's stack.
 
 Each 'navigation' item represents a navigation to a new coordinator. All view controllers that the coordinator presents
 are stored in its associated nav stack item under the `viewControllersAndPresentMethods` property, where the view
 controller is stored with the present method it was presented with.
 */
public class Navigation {
    public let coordinator: BaseCoordinator
    public let presentMethod: PresentMethod
    public var viewControllersAndPresentMethods: [(vc: UIViewController, presentMethod: PresentMethod)] = []
    internal let parentCoordinator: SubNavigating?
    
    internal init(coordinator: BaseCoordinator, presentMethod: PresentMethod, parentCoordinator: SubNavigating?) {
        self.coordinator = coordinator
        self.presentMethod = presentMethod
        self.parentCoordinator = parentCoordinator
    }
}

// TODO: Move the nav stack from the navigator into a dedicated manager
//internal class NavigationStackManager {
//    let shared: NavigationStackManager = NavigationStackManager()
//
//    private(set) var stack: [NavigationStackItem] = []
//
//    func coordinatorDidAppear(_ coordinator: BaseCoordinator) {
//
//    }
//
//    func viewControllerWasPresented(_ viewController: UIViewController) {
//
//    }
//
//    func viewControllerWasDismissed(_ viewController: UIViewController) {
//
//    }
//}

