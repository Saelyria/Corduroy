
import Foundation

/**
 Describes a coordinator that has preconditions that must be fulfilled before navigation to it is allowed.
 */
public protocol NavigationPreconditionRequiring: BaseCoordinator {
    /// Whether the navigator should sort the preconditions array when evaluating them. If `true`, the navigator will
    /// evaluate non-asynchronous preconditions (i.e. non-`RecoveringNavigationPrecondition`s) before asynchronous ones
    /// in order to fail faster in case of a failure, otherwise it will evaluate preconditions in the array's order.
    /// Defaults to `true`.
    var shouldSortPreconditions: Bool { get }
    
    /// The array of preconditions that must pass in order to navigate to this coordinator.
    static var preconditions: [NavigationPrecondition.Type] { get }
}

public extension NavigationPreconditionRequiring {
    var shouldSortPreconditions: Bool {
        return true
    }
}



/**
 Describes an object that describes a precondition that must be fulfilled for navigation to a given coordinator.
 
 A `NavigationPrecondition` object is used by the `Navigator` to determine if navigation is allowed to a given
 coordinator. The navigator will determine this by calling the precondition's `evaluate(context:)` method and,
 based on whether or not an error is returned in the completion closure, will continue with navigation or not to the
 coordinator being navigated to. Precondition objects are created by the navigator shortly before the time of their
 evaluation.
 
 Note that a precondition can instantly call their `completion` (as the case would be if the precondition was based on
 readily- or globally-available variables), but this can be called asynchronously (such as if a network request must be
 completed as a part of the precondition).
 */
public protocol NavigationPrecondition {
    init()
    
    /**
     Evaluates whether the precondition passes. This is called when a navigation takes place with this precondition.
     - parameter context: A context object containing details about the navigation.
     - throws: An error about why the precondition did not pass.
     */
    func evaluate(context: Navigator.NavigationContext) throws
}



/**
 Describes a navigation precondition that, when a precondition is not met, can attempt to recover asynchronously.
 */
public protocol RecoveringNavigationPrecondition: NavigationPrecondition {
    /**
     Evaluates whether the precondition passes. This is called when a navigation takes place with this precondition.
     - parameter context: A context object containing details about the navigation.
     - parameter completion: A closure the precondition should call when it has decided that it passes (indicated by
     passing `nil` or fails (by passing an `Error` object).
     */
    func attemptRecovery(context: Navigator.NavigationContext, completion: @escaping (Error?) -> Void)
}



/**
 Describes a navigation precondition that, when a precondition is not met, will attempt to recover with the result of a
 flow coordinator.
 
 An ideal sample use case for this protocol would be a login precondition which will pass if the user is already logged
 in, but will instead start some kind of login flow coordinator if the user is not already logged in.
 
 Note that the `attemptRecovery(context:completion:)` of the `RecoveringNavigationPrecondition` protocol is implemented
 via an extension and should not be implemented by a conforming type.
 */
public protocol FlowRecoveringNavigationPrecondition: RecoveringNavigationPrecondition {
    /// The type of flow coordinator that will be used for recovery if the precondition is not already met when its
    /// `evaluateIfRecoveryNeeded(context:)` method is called. This flow coordinator must have a `SetupModel` type of
    /// `Void`.
    associatedtype RecoveringFlowCoordinator: FlowCoordinator where RecoveringFlowCoordinator.SetupModel == Void
    
    /// The present method that should be used for the precondition's recovery flow coordinator.
    var recoveryCoordinatorPresentMethod: PresentMethod { get }
}

public extension FlowRecoveringNavigationPrecondition {
    func attemptRecovery(context: Navigator.NavigationContext, completion: @escaping (Error?) -> Void) {
        context.navigator.navigateForFlowRecoveringPrecondition(self, completion: completion)
    }
}



/// An error representing an aggregate of underlying errors.
struct AggregateError: Error {
    let underlyingErrors: [Error]
}

