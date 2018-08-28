import UIKit

/**
 An internal model type that holds the information of a navigation operation that is stored on a navigator's stack.
 
 Each nav stack item represents a navigation to a new coordinator. All view controllers that the coordinator presents
 are stored in its associated nav stack item under the `viewControllersAndPresentMethods` property, where the view
 controller is stored with the present method it was presented with.
 */
public class NavStackItem {
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

/// Holds all the information for a navigation performed with the navigator. Acts as an 'edge' on the navigation graph.
public class Navigation {
    public let fromCoordinator: BaseCoordinator
    public let toCoordinator: BaseCoordinator
    public let presentMethod: PresentMethod
    public private(set) var isCurrent: Bool
    
    public init(from: BaseCoordinator, to: BaseCoordinator, method: PresentMethod, isCurrent: Bool) {
        self.fromCoordinator = from
        self.toCoordinator = to
        self.presentMethod = method
        self.isCurrent = isCurrent
    }
}

public class NavigationGraphManager {
    
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

