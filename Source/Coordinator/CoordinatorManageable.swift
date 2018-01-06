
import UIKit

/**
 A protocol to be implemented by view controllers wishing to be managed by a coordinator.
 
 A view controller implementing this protocol should be managed by a `Coordinator` object, meaning it should not
 implement any of its own navigation logic and should instead delegate interactions that it expects would start a
 navigation to its coordinator. Effectively, the view controller should know when to expect a navigation to happen (for
 example, from a 'Continue' or 'Open Settings' button) and decide to let its coordinator know, but the coordinator
 should ultimately decide whether to go through with that navigation and where to navigate to.
 */
public protocol CoordinatorManageable where Self: UIViewController {
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
    associatedtype ManagingCoordinator
    
    /// The coordinator managing the view controller.
    var coordinator: ManagingCoordinator? { get set }
}
