
import Foundation

/**
 An enum describing a type of navigation between view controllers, such as a navigation controller push or modal
 present.
 */
public enum NavigationMethod {
    case addAsChild
    case push
    case pop
    case present
    case dismiss
}

public enum NavigationParameter {
    case modalTransitionStyle(UIModalTransitionStyle)
    case modalPresentationStyle(UIModalPresentationStyle)
}

/**
 An object that handles navigation between coordinators.
 
 All navigation between coordinators should be handled through a `Router` object. The router will handle the creation of
 navigation context objects (which hold information like the involved coordinators) and evaluate any preconditions that
 a coordinator may have as a requirement for navigation to it.
 */
public class Navigator {
    /**
     An object containing information about a navigation operation, most notably the involved coordinators and the
     current view controller that the 'to' coordinator should start from.
     */
    public struct NavigationContext {
        /// The current view controller managed by the from coordinator that the to coordinator should navigate from.
        public let currentViewController: UIViewController
        /// The coordinator being navigated away from.
        public let fromCoordinator: BaseCoordinator?
        /// The coordinator being navigated to.
        public let toCoordinator: BaseCoordinator
        /// The navigation method requested to be used to present the to coordinator's first view controller.
        public let requestedNavigationMethod: NavigationMethod?
        /// Other parameters for the navigation, such as the requested modal presentation style.
        public let parameters: [NavigationParameter]
        
        fileprivate init(viewController: UIViewController, from: BaseCoordinator?, to: BaseCoordinator, by: NavigationMethod?) {
            self.currentViewController = viewController
            self.fromCoordinator = from
            self.toCoordinator = to
            self.requestedNavigationMethod = by
            self.parameters = []
        }
    }
    
    /// The root view controller set as the main window's root view controller.
    public let rootViewController: UIViewController = UIViewController()
    
    private var currentCoordinator: BaseCoordinator!
    
    public convenience init<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T) where T.SetupModel == Void {
        self.init(onWindow: window, firstCoordinator: firstCoordinator, with: ())
    }
    
    public required init<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T, with model: T.SetupModel) {
        window.rootViewController = self.rootViewController
        window.makeKeyAndVisible()
        self.currentCoordinator = firstCoordinator
        let context = NavigationContext(viewController: self.rootViewController, from: nil, to: firstCoordinator, by: .addAsChild)
        firstCoordinator.start(with: model, context: context)
    }
    
    // MARK: Coordinator routing methods
    
    /// Navigate to the specified coordinator.
    public func navigate<T: Coordinator>(to coordinator: T, by navigationMethod: NavigationMethod) where T.SetupModel == Void {
        self.navigate(to: coordinator, with: (), by: navigationMethod)
    }
    
    /// Navigate to the specified coordinator with the given setup model.
    public func navigate<T: Coordinator>(to coordinator: T, with model: T.SetupModel, by navigationMethod: NavigationMethod) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        guard !(coordinator is NavigationPreconditionRequiring) else {
            fatalError("The specified coordinator has preconditions for navigation that must be checked - use the throwing `route(to:with)` method instead.")
        }
        
        let context: NavigationContext = NavigationContext(viewController: viewController, from: self.currentCoordinator, to: coordinator, by: navigationMethod)
        self.currentCoordinator = coordinator
        coordinator.start(with: model, context: context)
    }
    
    /// Navigate to the specified coordinator, evaluating the coordinator's preconditions and rethrowing any precondition
    /// errors that arise.
    public func navigate<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T, by navigationMethod: NavigationMethod) throws where T.SetupModel == Void {
        try self.navigate(to: coordinator, with: (), by: navigationMethod)
    }

    /// Navigate to the specified coordinator with the given setup model, evaluating the coordinator's preconditions and
    /// rethrowing any precondition errors that arise.
    public func navigate<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T, with model: T.SetupModel, by navigationMethod: NavigationMethod) throws {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        try self.evaluatePreconditions(on: coordinator, navigationMethod: navigationMethod)
        let context: NavigationContext = NavigationContext(viewController: viewController, from: self.currentCoordinator, to: coordinator, by: navigationMethod)
        self.currentCoordinator = coordinator
        coordinator.start(with: model, context: context)
    }
    
    // MARK: FlowCoordinator routing methods
    
    /// Navigate to the specified flow coordinator.
    public func navigate<T: FlowCoordinator>(to flowCoordinator: T, by navigationMethod: NavigationMethod, completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) where T.SetupModel == Void {
        self.navigate(to: flowCoordinator, with: (), by: navigationMethod, completion: completion)
    }
    
    /// Navigate to the specified flow coordinator.
    public func navigate<T: FlowCoordinator>(to flowCoordinator: T, with model: T.SetupModel, by navigationMethod: NavigationMethod, completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        guard !(flowCoordinator is NavigationPreconditionRequiring) else {
            fatalError("The specified coordinator has preconditions for navigation that must be checked - use the throwing `route(to:with)` method instead.")
        }
        
        let context: NavigationContext = NavigationContext(viewController: viewController, from: self.currentCoordinator, to: flowCoordinator, by: navigationMethod)
        self.currentCoordinator = flowCoordinator
        flowCoordinator.start(with: model, context: context, completion: completion)
    }
    
    /// Navigate to the specified flow coordinator, evaluating the flow coordinator's preconditions and rethrowing any
    /// precondition errors that arise.
    public func navigate<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinator: T, by navigationMethod: NavigationMethod, completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) throws where T.SetupModel == Void {
        try self.navigate(to: flowCoordinator, with: (), by: navigationMethod, completion: completion)
    }
    
    /// Navigate to the specified flow coordinator, evaluating the flow coordinator's preconditions and rethrowing any
    /// precondition errors that arise.
    public func navigate<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinator: T, with model: T.SetupModel, by navigationMethod: NavigationMethod, completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) throws {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        try self.evaluatePreconditions(on: flowCoordinator, navigationMethod: navigationMethod)
        let context: NavigationContext = NavigationContext(viewController: viewController, from: self.currentCoordinator, to: flowCoordinator, by: navigationMethod)
        self.currentCoordinator = flowCoordinator
        flowCoordinator.start(with: model, context: context, completion: completion)
    }
    
    private func evaluatePreconditions(on coordinator: NavigationPreconditionRequiring, navigationMethod: NavigationMethod) throws {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let context: NavigationContext = NavigationContext(viewController: viewController, from: self.currentCoordinator, to: coordinator, by: navigationMethod)
        var preconditionError: Error?
        for precondition: NavigationPrecondition in type(of: coordinator).preconditions {
            precondition.evaluate(context: context, completion: { (error: Error?) in
                preconditionError = error
            })
        }
        if let error = preconditionError {
            throw error
        }
    }
}
