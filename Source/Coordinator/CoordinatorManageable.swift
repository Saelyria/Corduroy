
import UIKit

/**
 A protocol to be implemented by view controllers wishing to be managed by a coordinator.
 
 A view controller implementing this protocol should be managed by a `Coordinator` object, meaning it should not
 implement any of its own navigation logic and should instead delegate interactions that it expects would start a
 navigation to its coordinator. Effectively, the view controller should know when to expect a navigation to happen (for
 example, from a 'Continue' or 'Open Settings' button) and decide to let its coordinator know, but the coordinator
 should ultimately decide whether to go through with that navigation and where to navigate to.
 
 Additionally, the view controller should not implement or override its own init methods for dependency injection;
 instead, its dependencies should be defined in a type and this type set as the view controller's `SetupModel`
 associated type. The coordinator will instantiate the view controller using its `create(context:coordinator:)` factory
 method, passing in an instance of the view controller's defined setup model. View controllers that don't need any
 dependencies injected can simply ignore this associated type; it will default to `Void` (an empty struct) if no
 explicit type is aliased.
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
    
    /// The type of the model object that contains all dependencies the view controller needs to be properly
    /// initialized. Defaults to 'Void' if no explicit type is set.
    associatedtype SetupModel = Void
    
    /// The coordinator managing the view controller.
    var coordinator: ManagingCoordinator! { get }
    
    /**
     Creates an instance of the view controller. In the implemented method, the view controller should be instantiated,
     configured with the given `context` object, then have its `coordinator` property set to the given `coordinator`.
     - parameter context: The context object containing all dependencies the view controller needs.
     - parameter coordinator: The coordinator the view controller will be managed by.
     */
    static func create(with model: SetupModel, coordinator: ManagingCoordinator) -> Self
}

public extension CoordinatorManageable where Self.SetupModel == Void {
    /**
     Creates an instance of the view controller. In the implemented method, the view controller should be instantiated
     then have its `coordinator` property set to the given `coordinator`.
     - parameter coordinator: The coordinator the view controller will be managed by.
     */
    static func create(coordinator: ManagingCoordinator) -> Self {
        return Self.create(with: (), coordinator: coordinator)
    }
}
