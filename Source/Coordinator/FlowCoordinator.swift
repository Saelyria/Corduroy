
import UIKit

/**
 A protocol describing an object that manages navigation in a user flow.
 
 A flow coordinator is a specialized navigation coordinator that is responsible for a set of view controllers in a user
 'flow'. A user flow is any series of view controllers that are launched with the intention of completing a specific
 task or returning a specific value; for example, starting a flow to have the user authenticate or starting a flow to
 upload a picture. Flows have a defined start and end.
 
 Flow coordinators are started by other coordinators and are expected to, once completed, call their delegate's
 `coordinatorDidCompleteFlow(_:fromVC:context:)` method, with `context` being an object of the flow coordinator's
 `FlowCompletionContextType`. This context type could be, as in the example of authentication, a type that contains
 information about whether the authentication was successful and, if so, the credentials for the authentication.
*/
public protocol FlowCoordinator: BaseCoordinator, NavigationPrecondition {
    /// The type of the model object that contains all dependencies the coordinator needs to be properly initialized.
    /// Defaults to 'Void' if no explicit type is set.
    associatedtype SetupModel = Void
    
    /// The type of the model object that this flow coordinator will return in its completion containing data about or
    /// as a result of its flow. Defaults to 'EmptyContext' if no explicit type is set.
    associatedtype FlowCompletionContext = Void
    
    typealias FlowCompletion = (Error?, FlowCompletionContext?) -> Void
    
    /**
     Starts the coordinator with the given setup model, navigation context, and flow completion handler.
     - parameter model: The model object containing all dependencies the coordinator needs.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     - parameter completion: A closure to call after the flow has completed.
     */
    func start(with model: SetupModel, context: Navigator.NavigationContext, completion: @escaping FlowCompletion)
}

public extension FlowCoordinator where Self.FlowCompletionContext == Void, Self.SetupModel == Void {
    /**
     Starts the coordinator with the navigation context and flow completion handler.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     - parameter completion: A closure to call after the flow has completed.
     */
    func start(context: Navigator.NavigationContext, completion: @escaping (Error?) -> Void) {
        let fullCompletion = { (error: Error?, context: FlowCompletionContext?) in
            completion(error)
        }
        self.start(with: (), context: context, completion: fullCompletion)
    }
}

public extension FlowCoordinator where Self.FlowCompletionContext == Void {
    /**
     Starts the coordinator with the given setup model, navigation context, and flow completion handler.
     - parameter model: The model object containing all dependencies the coordinator needs.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     - parameter completion: A closure to call after the flow has completed.
     */
    func startFlow(with model: SetupModel, context: Navigator.NavigationContext, completion: @escaping (Error?) -> Void) {
        let fullCompletion = { (error: Error?, context: FlowCompletionContext?) in
            completion(error)
        }
        self.start(with: model, context: context, completion: fullCompletion)
    }
}

public extension FlowCoordinator where Self.SetupModel == Void {
    /**
     Starts the coordinator with the given navigation context and flow completion handler.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     - parameter completion: A closure to call after the flow has completed.
     */
    func startFlow(context: Navigator.NavigationContext, completion: @escaping (Error?, FlowCompletionContext?) -> Void) {
        self.start(with: (), context: context, completion: completion)
    }
}
