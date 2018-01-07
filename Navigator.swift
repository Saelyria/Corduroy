
import Foundation

/**
 An enum describing a type of navigation between view controllers, such as a navigation controller push or modal
 present.
 */
public protocol NavigationMethod { }

public enum PresentMethod: NavigationMethod {
    case pushing
    case modallyPresenting
    case addingAsChild
}

public enum DismissMethod: NavigationMethod {
    case popping
    case modallyDismissing
    case removingFromParent
}


/**
 An enum describing an additional parameter regarding view controller navigation that a coordinator should follow.
*/
public enum NavigationParameter {
    case modalTransitionStyle(UIModalTransitionStyle)
    case modalPresentationStyle(UIModalPresentationStyle)
}



/**
 An object that handles navigation between coordinators.
 
 All navigation between coordinators should be handled through a `Navigator` object. The navigator will handle the
 creation of navigation context objects (which hold information like the involved coordinators) and evaluate any
 preconditions that a coordinator may have as a requirement for navigation to it.
 */
public class Navigator {
    /**
     An object containing information about a navigation operation, most notably the involved coordinators and the
     current view controller that the 'to' coordinator should start from.
     */
    public struct NavigationContext {
        /// The current view controller managed by the from coordinator that the to coordinator should navigate from.
        public let currentViewController: UIViewController
        /// The coordinator being navigated away from. Will be `nil` if this is the first coordinator navigation.
        public let fromCoordinator: BaseCoordinator?
        /// The coordinator being navigated to.
        public let toCoordinator: BaseCoordinator
        /// The navigation method requested to be used to present the to coordinator's first view controller. Can be a
        /// case of either `DismissMethod` or `PresentMethod`.
        public let requestedNavigationMethod: NavigationMethod
        /// Other parameters for the navigation, such as the requested modal presentation style.
        public let parameters: [NavigationParameter]
        /// The navigator handling the navigation.
        public let navigator: Navigator
        
        fileprivate init(navigator: Navigator, viewController: UIViewController, from: BaseCoordinator?, to: BaseCoordinator, by: NavigationMethod) {
            self.navigator = navigator
            self.currentViewController = viewController
            self.fromCoordinator = from
            self.toCoordinator = to
            self.requestedNavigationMethod = by
            self.parameters = []
        }
    }
    
    /// The root view controller set as the main window's root view controller.
    public let rootViewController: UIViewController = RootViewController()
    
    public var currentCoordinator: BaseCoordinator {
        return self.coordinators.last!
    }
    
    public private(set) var coordinators: [BaseCoordinator] = []
    
    private var hasStarted: Bool = false
    
    public init() { }
    
    public func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T) {
        guard self.hasStarted == false else {
            return
        }
        
        window.rootViewController = self.rootViewController
        window.makeKeyAndVisible()
        self.coordinators.append(firstCoordinator)
        let context = NavigationContext(navigator: self, viewController: self.rootViewController, from: nil, to: firstCoordinator, by: PresentMethod.addingAsChild)
        firstCoordinator.start(context: context)
    }
    
    // MARK: Coordinator routing methods

    /// Navigate to the specified coordinator with the given setup model.
    public func go<T: Coordinator>(to coordinator: T, by navMethod: PresentMethod = .pushing) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        guard !(coordinator is NavigationPreconditionRequiring) else {
            fatalError("The specified coordinator has preconditions for navigation that must be checked - use the throwing `route(to:by)` method instead.")
        }
        
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: coordinator, by: navMethod)
        self.coordinators.append(coordinator)
        coordinator.start(context: context)
    }

    /// Navigate to the specified coordinator with the given setup model, evaluating the coordinator's preconditions and
    /// rethrowing any precondition errors that arise.
	public func go<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T, by navMethod: PresentMethod = .pushing) throws {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        try self.evaluatePreconditions(on: coordinator, navMethod: navMethod)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: coordinator, by: navMethod)
        self.coordinators.append(coordinator)
        coordinator.start(context: context)
    }
    
    public func `return`<T: Coordinator>(from coordinator: T, by method: DismissMethod = .popping) {
        
    }
    
    // MARK: FlowCoordinator routing methods
	
    /// Navigate to the specified flow coordinator.
    public func go<T: FlowCoordinator>(to flowCoordinator: T, by navMethod: PresentMethod = .modallyPresenting,
    completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        guard !(flowCoordinator is NavigationPreconditionRequiring) else {
			fatalError("The specified coordinator has preconditions for navigation that must be checked - use the throwing `route(to:by:completion)` method instead.")
        }
        
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: flowCoordinator, by: navMethod)
        self.coordinators.append(flowCoordinator)
        flowCoordinator.start(context: context, completion: completion)
    }
	
    /// Navigate to the specified flow coordinator, evaluating the flow coordinator's preconditions and rethrowing any
    /// precondition errors that arise.
	public func go<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinator: T, by navMethod: PresentMethod = .modallyPresenting,
    completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) throws {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        try self.evaluatePreconditions(on: flowCoordinator, navMethod: navMethod)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: flowCoordinator, by: navMethod)
        self.coordinators.append(flowCoordinator)
        flowCoordinator.start(context: context, completion: completion)
    }
    
    public func `return`<T: FlowCoordinator>(from flowCoordinator: T, by method: DismissMethod = .modallyDismissing) {
        
    }
    
    // MARK: Precondition evaluation
    
    internal func navigateForPrecondition<T: FlowRecoveringNavigationPrecondition>(_ precondition: T, by navMethod: PresentMethod?,
    completion: FlowRecoveringNavigationPrecondition.Completion) {
        
    }
    
    private func evaluatePreconditions(on coordinator: NavigationPreconditionRequiring, navMethod: NavigationMethod) throws {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: coordinator, by: navMethod)
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

/**
 An internal view controller type used as the root view controller of the window. This view controller ensures that the
 status bar style and hidden state are set by its child view controller.
 */
fileprivate class RootViewController: UIViewController {
    var childViewController: UIViewController?
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.childViewController
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.childViewController
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        self.childViewController = childController
    }
}
