
import UIKit

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
    /// The type of the model object that this flow coordinator will return in its completion
    /// containing data about or as a result of its flow. Defaults to 'EmptySetupContext' if no
    /// explicit type is set.
    associatedtype FlowCompletionContextType = EmptyContext
    
    /// The delegate the flow coordinator will inform about flow related events, notable about when its
    /// flow has completed.
    var flowDelegate: NavigationFlowCoordinatorDelegate? { get }
}



/**
 A protocol describing an object that receives events from a flow coordinator.
 */
public protocol NavigationFlowCoordinatorDelegate {
    /**
     Called when a flow coordinator has completed its flow.
     - parameter coordinator: The flow coordinator that completed.
     - parameter fromVC: The view controller the coordinator finished on.
     - parameter context: The completion context of the coordinator's `FlowCompletionContextType`.
     */
    func coordinatorDidCompleteFlow<CoordinatorType: NavigationFlowCoordinator>(_ coordinator: CoordinatorType, from fromVC: UIViewController, with context: CoordinatorType.FlowCompletionContextType)
}
