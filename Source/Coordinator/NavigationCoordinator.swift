
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
    associatedtype SetupContext = EmptyContext
    
    /// The delegate the coordinator will inform about flow-related events.
    var delegate: NavigationCoordinatorDelegate? { get set }
    
    /**
     Starts the coordinator from the given view controller.
     - parameter context: The context object containing all dependencies the coordinator needs.
     - parameter fromVC: The view controller the coordinator should start its navigation from.
     */
    func start(with context: SetupContext, from fromVC: UIViewController)
}



/**
 A protocol describing an object that manages navigation in a user flow.
 
 A flow coordinator is a specialized navigation coordinator that is responsible for a set of
 view controllers in a user 'flow'. A user flow is any series of view controllers that are
 launched with the intention of completing a specific task or returning a specific value; for
 example, starting a flow to have the user authenticate or starting a flow to upload a picture.
 Flows typically have a defined start and end.
 
 Flow coordinators are started by other coordinators and are expected to, once completed,
 call the passed in `completion` closure. In this closure, the flow coordinator passes in
 itself and a `FlowCompletionContext` object it defines as an associated type. This context
 type could be, as in the example of authentication, a type that contains information about
 whether the authentication was successful and, if so, the credentials for the authentication.
 */
public protocol NavigationFlowCoordinator: NavigationCoordinator {
    /// The type of the model object that this flow coordinator will return in its completion
    /// block as a result of its flow. Defaults to 'EmptySetupContext' if no explicit type is set.
    associatedtype FlowCompletionContext = EmptyContext
    
    /// The delegate the coordinator will inform about flow-related events, notably when it has
    /// completed its flow.
    var flowDelegate: NavigationFlowCoordinatorDelegate? { get set }
}

public extension NavigationFlowCoordinator {
    var delegate: NavigationCoordinatorDelegate? {
        get {
            return self.flowDelegate
        }
        set {
            if let flowDelegate = newValue as? NavigationFlowCoordinatorDelegate {
                self.flowDelegate = flowDelegate
            }
        }
    }
}

/**
 
*/
public protocol NavigationCoordinatorDelegate {
    func navigationCoordinatorDidStart<SetupType>(_ coordinator: AnyNavigationCoordinator<SetupType>)
}

public protocol NavigationFlowCoordinatorDelegate: NavigationCoordinatorDelegate {
    func flowNavigationCoordinator<SetupType, CompletionType>(_ coordinator: AnyNavigationFlowCoordinator<SetupType, CompletionType>, didFinishWithContext completionContext: CompletionType)
}

public extension NavigationFlowCoordinatorDelegate {
    func navigationCoordinatorDidStart<SetupType>(_ coordinator: AnyNavigationCoordinator<SetupType>) { }
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
    associatedtype ManagingCoordinator
    /// The type of the model object that contains all dependencies the view controller needs
    /// to be properly initialized. Defaults to 'EmptySetupContext' if no explicit type is set.
    associatedtype SetupContext = EmptyContext
    
    /// The coordinator managing the view controller.
    var coordinator: ManagingCoordinator! { get }
    
    /**
     Creates an instance of the view controller.
     - parameter context: The context object containing all dependencies the view controller needs.
     - parameter coordinator: The coordinator the view controller will be managed by.
     */
    static func create(with context: SetupContext, coordinator: ManagingCoordinator) -> Self
}

/**
 A struct that can be used as the SetupContext or FlowCompletionContext for a NavigationCoordinator,
 FlowNavigationController, or NavigationCoordinatorManageable that requires no dependencies to be
 initialized.
 */
public struct EmptyContext {
    public init() { }
}

