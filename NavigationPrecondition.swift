
import Foundation

/**
 Describes a coordinator that has preconditions that must be fulfilled before navigation to it is allowed.
 */
public protocol NavigationPreconditionRequiring: BaseCoordinator {
    /// The array of preconditions that must pass in order to navigate to this coordinator.
    static var preconditions: [NavigationPrecondition] { get }
}

/**
 Describes an object that will determine if navigation is allowed.
 
 A `NavigationPrecondition` object is used by the `Navigator` to determine if navigation is allowed to a given
 coordinator. The navigator will determine this by calling the precondition's `evaluate(context:completion:) block and,
 based on whether or not an error is returned in the completion closure, will continue with navigation or not to the
 coordinator being navigated to.
 */
public protocol NavigationPrecondition {
    typealias Completion = (Error?) -> Void
    
    func evaluate(context: Navigator.NavigationContext, completion: @escaping Completion)
}

extension NavigationPrecondition {
    var identifier: String {
        return String(describing: Self.self)
    }
}

/**
 Describes a navigation precondition that, when a precondition is not already met, will attempt to fulfill it with the
 result of a flow coordinator.
 
 
 */
public protocol FlowRecoveringNavigationPrecondition: NavigationPrecondition {
    associatedtype RecoveringFlowCoordinator: FlowCoordinator
    
    var preconditionAlreadyPasses: Bool { get }
    
    var coordinatorModel: RecoveringFlowCoordinator.SetupModel { get }
    var coordinatorNavigationMethod: NavigationMethod { get }
    
    init(coordinatorModel: RecoveringFlowCoordinator.SetupModel, coordinatorNavigationMethod: NavigationMethod)
}

extension FlowRecoveringNavigationPrecondition {
    func evaluate(context: Navigator.NavigationContext, completion: @escaping Completion) {
        if self.preconditionAlreadyPasses {
            completion(nil)
        } else {
            context.navigator.navigateForPrecondition(self, with: self.coordinatorModel, by: self.coordinatorNavigationMethod, completion: completion)
        }
    }
}
