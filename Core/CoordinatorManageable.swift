
import UIKit

/**
 Describes a view controller wishing to be managed by a coordinator.
 
 A view controller implementing this protocol should be managed by a `Coordinator` object, meaning it should not
 implement any of its own navigation logic and should instead delegate interactions that it expects would start a
 navigation to its coordinator. Effectively, the view controller should know when to expect a navigation to happen (for
 example, from a 'Continue' or 'Open Settings' button) and decide to let its coordinator know, but the coordinator
 should ultimately decide whether to go through with that navigation and where to navigate to.
 */
public protocol CoordinatorManageable {
    /**
     A type the `NavigationCoordinator` that manages this view controller should be or conform to in order to receive
     navigation events from this view controller. For better decoupling, best practice is for a view controller to have
     a custom delegate protocol (e.g. a protocol named `ThisViewControllerCoordinator`) that defines all of the events
     that this view controller expects its coordinator to handle as navigation.
     
     For example, `ThisViewControllerCoordinator` could contain requirements like
     `thisViewControllerDidPressContinue(_:)` or other button delegate events. The view controller would then typealias
     its `ManagingCoordinator` to 'ThisViewControllerCoordinator'. This way, the view controller can be managed by any
     `Coordinator` object that additionally implements `ThisViewControllerCoordinator` instead of coupling to a specific
     coordinator, unless tighter coupling is desired to ensure the view controller can only be handled by a specific
     `Coordinator`.
     */
    associatedtype ManagingCoordinator: AnyObject
    
    /// The coordinator managing the view controller.
    var coordinator: ManagingCoordinator? { get set }
}



/**
 Describes a view controller that manages its own navigation logic.
 
 A view controller that's fairly simple and is highly coupled to its navigation logic can choose to coordinate itself
 by implementing this protocol. This view controller can then be treated like any other coordinator - it can be
 navigated to and from using a navigator, have preconditions for its navigation, and everything else that a coordinator
 is afforded.
 
 A self-coordinating view controller does not need to implement its `currentViewController` or `coordinator` properties;
 by default, these will both return `self`. It will still, however, have to implement the `create(with:)` and
 `presentViewController(context:)` methods found on `Coordinator`.
 */
public protocol SelfCoordinating: Coordinator { }

public extension SelfCoordinating where Self: UIViewController {
    func presentViewController(context: NavigationContext) {
        self.present(self, asDescribedBy: context)
    }
}

public extension SelfCoordinating where Self: UIViewController, Self.SetupModel == Void {
    // NOTE: This default behaviour should be overriden for view controllers that must be initiated from storyboards.
    static func create(with model: SetupModel, navigator: Navigator) -> Self {
        let selfCoordinatingVC = Self()
        selfCoordinatingVC.navigator = navigator
        return selfCoordinatingVC
    }
}
