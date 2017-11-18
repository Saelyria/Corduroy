
import UIKit

/**
 A protocol describing an object that manages navigation between view controllers.
 
 A coordinator object is responsible for managing the navigation between view controllers,
 containing all navigation logic within itself. Coordinators should act as delegates for
 actions in view controllers (such as a button press or other action the user performed)
 that would trigger navigation to a new view controller.
 
 Dependencies for a coordinator can be defined via its `SetupContext` associated type.
 An object of this type is passed in to the `start(with:,fromViewController:)` method
 of the coordinator to have the coordinator present its first view controller from the
 given view controller. This `SetupContext` associated type defaults to `EmptySetupContext`
 if no explicit type is set.
 */
public protocol NavigationCoordinator {
    /// The type of the model object that contains all dependencies the coordinator needs
    /// to be properly initialized. Defaults to 'EmptySetupContext' if no explicit type is set.
    associatedtype SetupContextType = EmptyContext
    
    /// The delegate the flow coordinator will inform about navigation related events.
    var delegate: NavigationCoordinatorDelegate? { get }
    
    /**
     Starts the coordinator from the given view controller.
     - parameter context: The context object containing all dependencies the coordinator needs.
     - parameter fromVC: The view controller the coordinator should start its navigation from.
     */
    func start(with context: SetupContextType, from fromVC: UIViewController)
}



/**
 A protocol describing an object that receives events from a navigation coordinator.
 */
public protocol NavigationCoordinatorDelegate {
    /**
     Called when a flow coordinator has completed its flow.
     - parameter coordinator: The coordinator that handled the navigation.
     - parameter toVC: The view controller the coordinator navigated to.
     */
    func coordinatorDidNavigate<CoordinatorType: NavigationCoordinator>(_ coordinator: CoordinatorType, to toVC: UIViewController)
}


/**
 A struct that can be used as the SetupContext or FlowCompletionContext for a NavigationCoordinator,
 FlowNavigationController, or NavigationCoordinatorManageable that requires no dependencies to be
 initialized.
 */
public struct EmptyContext {
    public init() { }
}

