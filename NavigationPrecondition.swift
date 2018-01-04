
import Foundation

public protocol NavigationPrecondition {
    static var identifier: String { get }
    
    func evaluate(context: NavigationContext, completion: @escaping (Error?) -> Void)
}

public extension NavigationPrecondition {
    static var identifier: String {
        return String(describing: Self.self)
    }
}

public extension NavigationPrecondition where Self: FlowCoordinator, Self.SetupContext == Void {
    func evaluate(context: NavigationContext, completion: @escaping (Error?) -> Void) {
        self.startFlow(with: (), from: context.currentViewController) { (error, _) in
            completion(error)
        }
    }
}
