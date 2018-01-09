
import Foundation

/**
 An enum describing a type of navigation between view controllers, such as a navigation controller push/pop or modal
 present/dismiss. Can be either `PresentMethod` or `DismissMethod`.
 */
public protocol NavigationMethod { }

/**
 An enum describing a type of presentation between view controllers, such as a navigation controller push or modal
 present.
 */
public enum PresentMethod: NavigationMethod {
    case pushing
    case modallyPresenting
    case addingAsChild
}

/**
 An enum describing a type of dismissal between view controllers, such as a navigation controller pop or modal
 dismiss.
 */
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
    case animateNavigation(Bool)
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
    
    /// The coordinator coordinating the currently shown view controller.
    public var currentCoordinator: BaseCoordinator {
        return self.coordinators.last!
    }
    
    /// The current stack of coordinators in historical order of their navigation.
    public private(set) var coordinators: [BaseCoordinator] = []
    
    // The present methods used for each coordinator in the stack by their `identifier`.
    private var coordinatorPresentMethods: [String: PresentMethod] = [:]
    
    private var hasStarted: Bool = false
    private var previousCoordinator: BaseCoordinator? {
        guard self.coordinators.count >= 2 else {
            return nil
        }
        
        return self.coordinators[self.coordinators.count-2]
    }
    
    public init() { }
    
    /**
     Start the navigator with the first coordinator.
     - parameter window: The root window that view controllers should be presented on.
     - parameter firstCoordinator: The type of coordinator to start the app from.
     */
    public func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T.Type) where T.SetupModel == Void {
        self.start(onWindow: window, firstCoordinator: firstCoordinator, with: ())
    }
    
    /**
     Start the navigator with the first coordinator.
     - parameter window: The root window that view controllers should be presented on.
     - parameter firstCoordinator: The type of coordinator to start the app from.
     - parameter model: A model of the given coordinator's setup model type.
     */
    public func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T.Type, with model: T.SetupModel) {
        guard !(firstCoordinator is NavigationPreconditionRequiring.Type) else {
            fatalError("The first coordinator of the app should not have navigation preconditions.")
        }
        guard self.hasStarted == false else { return }
        self.hasStarted = true
        
        let firstCoordinator = firstCoordinator.create(with: model, navigator: self)
        window.rootViewController = self.rootViewController
        window.makeKeyAndVisible()
        self.coordinators.append(firstCoordinator)
        let context = NavigationContext(navigator: self, viewController: self.rootViewController, from: nil, to: firstCoordinator, by: PresentMethod.addingAsChild)
        firstCoordinator.start(context: context)
    }
    
    // MARK: Coordinator navigation methods
    
    /**
     Navigate to the specified coordinator.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     */
    public func go<T: Coordinator>(to coordinator: T.Type, by navMethod: PresentMethod = .pushing) where T.SetupModel == Void {
        self.go(to: coordinator, by: navMethod, with: ())
    }
    
    /**
     Navigate to the specified coordinator with the given setup model.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     */
    public func go<T: Coordinator>(to coordinator: T.Type, by navMethod: PresentMethod = .pushing, with model: T.SetupModel) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        guard !(coordinator is NavigationPreconditionRequiring.Type) else {
            fatalError("The specified coordinator has preconditions for navigation that must be checked - use the throwing `route(to:by)` method instead.")
        }
        
        let coordinator = coordinator.create(with: model, navigator: self)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: coordinator, by: navMethod)
        self.coordinators.append(coordinator)
        self.coordinatorPresentMethods[coordinator.identifier] = navMethod
        coordinator.start(context: context)
    }
    
    /**
     Navigate to the specified coordinator, evaluating the coordinator's preconditions and rethrowing any precondition
     errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     */
    public func go<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod = .pushing) throws where T.SetupModel == Void {
        try self.go(to: coordinator, by: navMethod, with: ())
    }
    
    /**
     Navigate to the specified coordinator with the given setup model, evaluating the coordinator's preconditions and
     rethrowing any precondition errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     */
    public func go<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod = .pushing, with model: T.SetupModel) throws {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let coordinator = coordinator.create(with: model, navigator: self)
        try self.evaluatePreconditions(on: coordinator, navMethod: navMethod)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: coordinator, by: navMethod)
        self.coordinators.append(coordinator)
        self.coordinatorPresentMethods[coordinator.identifier] = navMethod
        coordinator.start(context: context)
    }
    
    // MARK: FlowCoordinator navigation methods
    
    /**
     Navigate to the specified flow coordinator.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter completion: The completion block the flow coordinator will call when its flow has completed.
     */
    public func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod = .modallyPresenting,
    completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) where T.SetupModel == Void {
        self.go(to: flowCoordinator, by: navMethod, with: (), completion: completion)
    }
    
    /**
     Navigate to the specified flow coordinator with the given setup model.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter completion: The completion block the flow coordinator will call when its flow has completed.
     */
    public func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod = .modallyPresenting, with model: T.SetupModel,
    completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        guard !(flowCoordinator is NavigationPreconditionRequiring.Type) else {
			fatalError("The specified coordinator has preconditions for navigation that must be checked - use the throwing `route(to:by:completion)` method instead.")
        }
        
        let flowCoordinator = flowCoordinator.create(with: model, navigator: self)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: flowCoordinator, by: navMethod)
        self.coordinators.append(flowCoordinator)
        self.coordinatorPresentMethods[flowCoordinator.identifier] = navMethod
        flowCoordinator.start(context: context, completion: completion)
    }
    
    /**
     Navigate to the specified flow coordinator, evaluating the coordinator's preconditions and rethrowing any
     precondition errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter completion: The completion block the flow coordinator will call when its flow has completed.
     */
    public func go<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod = .modallyPresenting,
    completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) throws where T.SetupModel == Void {
        try self.go(to: flowCoordinatorType, by: navMethod, with: (), completion: completion)
    }
	
    /**
     Navigate to the specified flow coordinator with the given setup model, evaluating the coordinator's preconditions
     and rethrowing any precondition errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter completion: The completion block the flow coordinator will call when its flow has completed.
     */
	public func go<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod = .modallyPresenting,
    with model: T.SetupModel, completion: @escaping (Error?, T.FlowCompletionContext?) -> Void) throws {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let flowCoordinator = flowCoordinatorType.create(with: model, navigator: self)
        try self.evaluatePreconditions(on: flowCoordinator, navMethod: navMethod)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
														   from: self.currentCoordinator, to: flowCoordinator, by: navMethod)
        self.coordinators.append(flowCoordinator)
        self.coordinatorPresentMethods[flowCoordinator.identifier] = navMethod
        flowCoordinator.start(context: context, completion: completion)
    }
    
    // MARK: Backwards navigation methods
    
    /**
     Navigate back to the previous coordinator.
     */
    public func goBack() {
        guard let previousCoordinator = self.previousCoordinator else { return }
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("Attempting to return from a coordinator whose `currentViewController` is not the currently active view controller.")
        }
        guard let coordinatorPresentMethod = self.coordinatorPresentMethods[self.currentCoordinator.identifier] else { return }
        
        let dismissMethod = self.inverseDismissMethod(for: coordinatorPresentMethod)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController,
                                                           from: self.currentCoordinator, to: previousCoordinator, by: dismissMethod)
        self.coordinators.removeLast()
        self.coordinatorPresentMethods.removeValue(forKey: self.currentCoordinator.identifier)
        self.currentCoordinator.dismiss(context: context)
    }
    
    /**
     Navigate back to the last coordinator of the specified coordinator type.
     - parameter coordinator: The type of coordinator to navigate back to.
     */
    public func goBack<T: Coordinator>(to coordinatorType: T.Type) {
        guard let coordinator = self.coordinators.filter({ $0 is T }).first else {
            return
        }
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
    
    private func inverseDismissMethod(`for` presentMethod: PresentMethod) -> DismissMethod {
        switch presentMethod {
        case .addingAsChild:
            return .removingFromParent
        case .modallyPresenting:
            return .modallyDismissing
        case .pushing:
            return .popping
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

fileprivate extension BaseCoordinator {
    /// An identifier used internally for coordinators.
    var identifier: String {
        return UUID().uuidString
    }
}
