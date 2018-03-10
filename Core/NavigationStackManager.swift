import UIKit

/**
 An internal model type that holds the information of a navigation operation that is stored on a navigator's stack.
 */
internal class NavStackItem {
    public let coordinator: BaseCoordinator
    public let presentMethod: PresentMethod
    public let canBeNavigatedBackTo: Bool
    public var viewControllersAndPresentMethods: [(vc: UIViewController, presentMethod: PresentMethod)] = []
    
    public init(coordinator: BaseCoordinator, presentMethod: PresentMethod, canBeNavigatedBackTo: Bool) {
        self.coordinator = coordinator
        self.presentMethod = presentMethod
        self.canBeNavigatedBackTo = canBeNavigatedBackTo
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

