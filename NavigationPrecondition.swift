
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
 */
public protocol NavigationPrecondition {
    func evaluate(context: Navigator.NavigationContext, completion: @escaping (Error?) -> Void)
}

extension NavigationPrecondition {
    var identifier: String {
        return String(describing: Self.self)
    }
}

public extension NavigationPrecondition where Self: FlowCoordinator, Self.SetupModel == Void {
    func evaluate(context: Navigator.NavigationContext, completion: @escaping (Error?) -> Void) {
        self.startFlow(context: context) { (error, _) in
            completion(error)
        }
    }
}
