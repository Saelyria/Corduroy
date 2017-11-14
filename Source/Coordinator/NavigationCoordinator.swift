
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
    
    /**
     Starts the coordinator from the given view controller.
     - parameter context: The context object containing all dependencies the coordinator needs.
     - parameter fromVC: The view controller the coordinator should start its navigation from.
     */
    func start(with context: SetupContextType, from fromVC: UIViewController)
}



/**
 A protocol describing an object that manages navigation in a user flow.
 
 A flow coordinator is a specialized navigation coordinator that is responsible for a set of
 view controllers in a user 'flow'. A user flow is any series of view controllers that are
 launched with the intention of completing a specific task or returning a specific value; for
 example, starting a flow to have the user authenticate or starting a flow to upload a picture.
 Flows have a defined start and end.
 
 Flow coordinators are started by other coordinators and are expected to, once completed,
 call the passed in `completion` closure. In this closure, the flow coordinator passes in
 itself the last view controller in its flow,  and a `FlowCompletionContextType` object it
 defines as an associated type. This context type could be, as in the example of authentication,
 a type that contains information about whether the authentication was successful and, if so, the
 credentials for the authentication.
 
 By default, a flow coordinator's `start(with:from)` method is unavailable and will cause a fatal
 error in development if called; this method can, however, be provided an implementation if the
 flow has a default destination it can finish its flow to.
 */
public protocol NavigationFlowCoordinator: NavigationCoordinator {
    /// The type of the model object that this flow coordinator will return in its completion containing
    /// data about or as a result of its flow. Defaults to 'EmptySetupContext' if no explicit type is set.
    associatedtype FlowCompletionContextType = EmptyContext
    
    /**
     The closure the coordinator will call upon completion of its flow.
     - parameter coordinator: The flow coordinator that just completed.
     - parameter fromVC: The last view controller of the flow, to be dismissed or presented from.
     - parameter completionContext: An object of the coordinator's `FlowCompletionContextType` containing
      information about or as a result of the completed flow.
     */
    typealias FlowCompletion = (_ coordinator: Self, _ fromVC: UIViewController, _ completionContext: FlowCompletionContextType) -> Void
    
    /**
     Starts the flow coordinator from the given view controller.
     - parameter context: The context object containing all dependencies the coordinator needs.
     - parameter fromVC: The view controller the coordinator should start its navigation from.
     - parameter completion: The closure the coordinator will call upon completion of its flow.
     */
    func startFlow(with context: SetupContextType, from fromVC: UIViewController, completion: @escaping FlowCompletion)
}

public extension NavigationFlowCoordinator {
    func start(with context: SetupContextType, from fromVC: UIViewController) {
        fatalError("start(with:from:) has not been implemented on this NavigationFlowCoordinator; please use its startFlow(with:from:completion:) method to start instead.")
    }
}



/**
 A protocol to be implemented by view controllers wishing to be managed by a coordinator.
 
 A view controller implementing this protocol should be managed by a NavigationCoordinator object.
 It should not implement its own init methods for dependency injection; instead, its dependencies
 should be defined in a type and this type set as the view controller's 'SetupContext' associated
 type. The coordinator will instantiate the view controller using its 'create(with:coordinator:)'
 factory method, passing in an instance of the view controller's defined setup model. This
 'SetupContext' associated type defaults to 'EmptySetupContext' if no explicit type is set.
 */
public protocol NavigationCoordinatorManageable where Self: UIViewController {
    /// A type the NavigationCoordinator that manages this view controller should be or conform
    /// to in order to receive navigation events from this view controller. For better decoupling,
    /// best practice is for a view controller to have a custom delegate type that this aliases to.
    associatedtype ManagingCoordinatorType
    /// The type of the model object that contains all dependencies the view controller needs
    /// to be properly initialized. Defaults to 'EmptySetupContext' if no explicit type is set.
    associatedtype SetupContextType = EmptyContext
    
    /// The coordinator managing the view controller.
    var coordinator: ManagingCoordinatorType! { get }
    
    /**
     Creates an instance of the view controller.
     - parameter context: The context object containing all dependencies the view controller needs.
     - parameter coordinator: The coordinator the view controller will be managed by.
     */
    static func create(with context: SetupContextType, coordinator: ManagingCoordinatorType) -> Self
}

/**
 A struct that can be used as the SetupContext or FlowCompletionContext for a NavigationCoordinator,
 FlowNavigationController, or NavigationCoordinatorManageable that requires no dependencies to be
 initialized.
 */
public struct EmptyContext {
    public init() { }
}

