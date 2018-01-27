
import UIKit

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
        public let parameters: [NavigationParameterKey: Any]
        /// The navigator handling the navigation.
        public let navigator: Navigator
        
        fileprivate init(navigator: Navigator, viewController: UIViewController, from: BaseCoordinator?,
                         to: BaseCoordinator, by: NavigationMethod, params: [NavigationParameterKey: Any]) {
            self.navigator = navigator
            self.currentViewController = viewController
            self.fromCoordinator = from
            self.toCoordinator = to
            self.requestedNavigationMethod = by
            self.parameters = NavigationParameterKey.defaultParameters(withOverrides: params)
        }
    }
    
    /// The root view controller set as the main window's root view controller.
    public let rootViewController: UIViewController = RootViewController()
    
    /// The coordinator coordinating the currently shown view controller.
    public var currentCoordinator: BaseCoordinator {
        return self.coordinators.last!
    }
    
    /// The current stack of coordinators in historical order of their navigation.
    public var coordinators: [BaseCoordinator] {
        let coordinators: [BaseCoordinator] = self.navigationStack.map({ $0.coordinator })
        return coordinators
    }
    private var previousCoordinator: BaseCoordinator? {
        guard self.coordinators.count >= 2 else { return nil }
        return self.coordinators[self.coordinators.count-2]
    }
    
    private var navigationStack: [NavStackItem] = []
    private var hasStarted: Bool = false
    
    // There's no reliable way to determine whether a back navigation from a UINavigationController was started by it
    // being explicitly told to do it vs. the back button of its nav bar being pressed, so we need this flag to
    // determine whether or not we should ignore calls to our `coordinatedNavControllerDidPopCoordinators` method so we
    // don't end up with duplicate calls.
    private var shouldIgnoreNavControllerPopRequests: Bool = false
    
    /// Initialize a new Navigator object.
    public init() { }
    
    /**
     Start the navigator with the first coordinator.
     - parameter window: The root window that view controllers should be presented on.
     - parameter firstCoordinator: The type of coordinator to start the app from.
     */
    @discardableResult
    public func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T.Type) -> T where T.SetupModel == Void {
        return self.start(onWindow: window, firstCoordinator: firstCoordinator, with: ())
    }
    
    /**
     Start the navigator with the first coordinator.
     - parameter window: The root window that view controllers should be presented on.
     - parameter firstCoordinator: The type of coordinator to start the app from.
     - parameter model: A model of the given coordinator's setup model type.
     */
    @discardableResult
    public func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T.Type, with model: T.SetupModel) -> T {
        guard !(firstCoordinator is NavigationPreconditionRequiring.Type) else {
            fatalError("The first coordinator of the app should not have navigation preconditions.")
        }
        guard self.hasStarted == false else {
            fatalError("The navigator's `start(onWindow:firstCoordinator:with:)` method was already called.")
        }
        self.hasStarted = true
        
        let firstCoordinator = firstCoordinator.create(with: model, navigator: self)
        window.rootViewController = self.rootViewController
        window.makeKeyAndVisible()
        let stackItem = NavStackItem(coordinator: firstCoordinator, presentMethod: .addingAsChild, canBeNavigatedBackTo: true)
        self.navigationStack.append(stackItem)
        let context = NavigationContext(navigator: self, viewController: self.rootViewController, from: nil,
                                        to: firstCoordinator, by: PresentMethod.addingAsChild, params: [:])
        firstCoordinator.presentFirstViewController(context: context)
        
        return firstCoordinator
    }
    
    // MARK: Coordinator navigation methods
    
    /**
     Navigate to the specified coordinator.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     */
    @discardableResult
    public func go<T: Coordinator>(to coordinator: T.Type, by navMethod: PresentMethod = .pushing,
    parameters: [NavigationParameterKey: Any] = [:]) -> T where T.SetupModel == Void {
        return self.go(to: coordinator, by: navMethod, with: (), parameters: parameters)
    }
    
    /**
     Navigate to the specified coordinator with the given setup model.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    @discardableResult
    public func go<T: Coordinator>(to coordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: [NavigationParameterKey: Any] = [:]) -> T {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        guard !(coordinator is NavigationPreconditionRequiring.Type) else {
            fatalError("The specified coordinator has preconditions for navigation that must be checked - use the throwing `evaluatePreconditionsAndGo(to:by:completion:)` method instead.")
        }
        
        let coordinator = coordinator.create(with: model, navigator: self)
        let context = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                        to: coordinator, by: navMethod, params: parameters)
        let stackItem = NavStackItem(coordinator: coordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
        self.navigationStack.append(stackItem)
        coordinator.presentFirstViewController(context: context)
        
        return coordinator
    }
    
    /**
     Navigate to the specified coordinator, evaluating the coordinator's preconditions and rethrowing any precondition
     errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter evaluationCompletion: The block called when the navigator has completed evaluation of preconditions,
        passing in either an error or the created coordinator.
     */
    public func evaluatePreconditionsAndGo<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod,
    parameters: [NavigationParameterKey: Any] = [:], evaluationCompletion: @escaping (Error?, T?) -> Void) where T.SetupModel == Void {
        self.evaluatePreconditionsAndGo(to: coordinator, by: navMethod, with: (), evaluationCompletion: evaluationCompletion)
    }
    
    /**
     Navigate to the specified coordinator with the given setup model, evaluating the coordinator's preconditions and
     rethrowing any precondition errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter evaluationCompletion: The block called when the navigator has completed evaluation of preconditions,
        passing in either an error or the created coordinator.
     */
    public func evaluatePreconditionsAndGo<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod,
    with model: T.SetupModel, parameters: [NavigationParameterKey: Any] = [:], evaluationCompletion: @escaping (Error?, T?) -> Void) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let coordinator = coordinator.create(with: model, navigator: self)
        let context = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                        to: coordinator, by: navMethod, params: parameters)
        let requiresRecovery = self.evaluatePreconditions(on: coordinator, context: context, completion: { (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    evaluationCompletion(error, nil)
                } else {
                    let stackItem = NavStackItem(coordinator: coordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
                    self.navigationStack.append(stackItem)
                    
                    evaluationCompletion(nil, coordinator)
                    coordinator.presentFirstViewController(context: context)
                }
            }
        })
        
        if requiresRecovery {
            self.currentCoordinator.onAsyncPreconditionEvaluationDidStart()
        }
    }
    
    // MARK: FlowCoordinator navigation methods
    
    /**
     Navigate to the specified flow coordinator.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
    public func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod,
    parameters: [NavigationParameterKey: Any] = [:], flowCompletion: @escaping (Error?, T.FlowCompletionContext?) -> Void) where T.SetupModel == Void {
        self.go(to: flowCoordinator, by: navMethod, with: (), flowCompletion: flowCompletion)
    }
    
    /**
     Navigate to the specified flow coordinator with the given setup model.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
    public func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: [NavigationParameterKey: Any] = [:], flowCompletion: @escaping (Error?, T.FlowCompletionContext?) -> Void) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        guard !(flowCoordinator is NavigationPreconditionRequiring.Type) else {
			fatalError("The specified coordinator has preconditions for navigation that must be checked - use the `evaluatePreconditionsAndGo(to:by:completion)` method instead.")
        }
        
        let flowCoordinator = flowCoordinator.create(with: model, navigator: self)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                                           to: flowCoordinator, by: navMethod, params: parameters)
        let stackItem = NavStackItem(coordinator: flowCoordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
        self.navigationStack.append(stackItem)
        flowCoordinator.presentFirstViewController(context: context, flowCompletion: flowCompletion)
    }
    
    /**
     Navigate to the specified flow coordinator, evaluating the coordinator's preconditions and rethrowing any
     precondition errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter evaluationCompletion: The block called when the navigator has completed evaluation of preconditions,
        passing in either an error or the created coordinator.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
    public func evaluatePreconditionsAndGo<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod,
    parameters: [NavigationParameterKey: Any] = [:], evaluationCompletion: @escaping (Error?, T?) -> Void,
    flowCompletion: @escaping (Error?, T.FlowCompletionContext?) -> Void) where T.SetupModel == Void {
        self.evaluatePreconditionsAndGo(to: flowCoordinatorType, by: navMethod, with: (), evaluationCompletion: evaluationCompletion, flowCompletion: flowCompletion)
    }
	
    /**
     Navigate to the specified flow coordinator with the given setup model, evaluating the coordinator's preconditions
     and rethrowing any precondition errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter evaluationCompletion: The block called when the navigator has completed evaluation of preconditions,
        passing in either an error or the created coordinator.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
	public func evaluatePreconditionsAndGo<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod,
    with model: T.SetupModel, parameters: [NavigationParameterKey: Any] = [:], evaluationCompletion: @escaping (Error?, T?) -> Void,
    flowCompletion: @escaping (Error?, T.FlowCompletionContext?) -> Void) {
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let flowCoordinator = flowCoordinatorType.create(with: model, navigator: self)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                                           to: flowCoordinator, by: navMethod, params: parameters)
        let requiresRecovery = self.evaluatePreconditions(on: flowCoordinator, context: context, completion: { (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    evaluationCompletion(error, nil)
                } else {
                    let stackItem = NavStackItem(coordinator: flowCoordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
                    self.navigationStack.append(stackItem)
                    evaluationCompletion(nil, flowCoordinator)
                    flowCoordinator.presentFirstViewController(context: context, flowCompletion: flowCompletion)
                }
            }
        })
        
        if requiresRecovery {
            self.currentCoordinator.onAsyncPreconditionEvaluationDidStart()
        }
    }
    
    // MARK: Backwards navigation methods
    
    /**
     Navigate back to the previous coordinator.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack(parameters: [NavigationParameterKey: Any] = [:]) {
        self.shouldIgnoreNavControllerPopRequests = true
        
        guard let previousCoordinator = self.previousCoordinator else { return }
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("Attempting to return from a coordinator whose `currentViewController` is not set.")
        }
        guard let presentMethod = self.navigationStack.last?.presentMethod else { return }
        
        let dismissMethod = presentMethod.inverseDismissMethod
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                                           to: previousCoordinator, by: dismissMethod, params: [:])
        self.navigationStack.removeLast()
        self.currentCoordinator.dismissViewControllers(context: context)
        self.currentCoordinator.onDismissal()
        
        self.shouldIgnoreNavControllerPopRequests = false
    }
    
    /**
     Navigate back to the last coordinator of the specified coordinator type.
     - parameter coordinatorType: The coordinator type to navigate back to.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack<T: BaseCoordinator>(toLast coordinatorType: T.Type, parameters: [NavigationParameterKey: Any] = [:]) {
        if let coordinatorIndex = self.coordinators.index(where: { $0 is T }) {
            let coordinator: BaseCoordinator = self.coordinators[coordinatorIndex]
            self.goBack(to: coordinator, parameters: parameters)
        }
    }
    
    /**
     Navigate back to the specified coordinator.
     - parameter coordinator: The coordinator to navigate back to.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack(to coordinator: BaseCoordinator, parameters: [NavigationParameterKey: Any] = [:]) {
        // start ignoring calls to 'go back' so we don't call it twice. See comment on `shouldIgnoreNavControllerPopRequests`'s declaration.
        self.shouldIgnoreNavControllerPopRequests = true
        
        // get the coordinators to be removed in order from the end and call their `dismiss(context:)` methods
        guard let coordinatorIndex = self.coordinators.index(where: { $0 === coordinator }) else { return }
        
        for index in stride(from: self.navigationStack.count-1, to: coordinatorIndex, by: -1) {
            let navStackItem = self.navigationStack[index]
            guard let viewController = navStackItem.coordinator.currentViewController else {
                fatalError("The currentViewController on a \(type(of: navStackItem.coordinator)) was nil")
            }
            let dismissMethod = navStackItem.presentMethod.inverseDismissMethod
            let coordinatorToRemove: BaseCoordinator = navStackItem.coordinator
            let coordinatorBeforeRemovedCoordinator: BaseCoordinator = self.coordinators[index-1]
            let params: [NavigationParameterKey: Any]
            if index == coordinatorIndex+1 {
                params = [NavigationParameterKey.animateTransition: false]
            } else {
                params = parameters
            }
            let context = NavigationContext(navigator: self, viewController: viewController, from: coordinatorToRemove,
                                            to: coordinatorBeforeRemovedCoordinator, by: dismissMethod, params: params)
            self.navigationStack.remove(at: index)
            coordinatorToRemove.dismissViewControllers(context: context)
            coordinatorToRemove.onDismissal()
        }
        
        self.shouldIgnoreNavControllerPopRequests = false
    }
    
    // MARK: UINavigationController methods
    
    internal func coordinatedNavControllerDidPopCoordinators(_ coordinators: [BaseCoordinator]) {
        guard self.shouldIgnoreNavControllerPopRequests == false else { return }
        
        for coordinator in coordinators {
            guard let lastCoordinator = self.navigationStack.last?.coordinator, lastCoordinator === coordinator else {
                fatalError("Misalignment of popped coordinators and the navigator's nav stack.")
            }
            
            self.navigationStack.removeLast()
            coordinator.onDismissal()
        }
    }
    
    // MARK: Precondition evaluation
    
    internal func navigateForFlowRecoveringPrecondition<T: FlowRecoveringNavigationPrecondition>(_ precondition: T,
    completion: @escaping (Error?) -> Void) {
        guard !(T.RecoveringFlowCoordinator.self is NavigationPreconditionRequiring.Type) else {
            fatalError("The flow coordinator for a flow recovering precondition must not require preconditions of its own.")
        }
        
        self.go(to: T.RecoveringFlowCoordinator.self, by: precondition.recoveryCoordinatorPresentMethod, flowCompletion: { (error: Error?, _) in
            completion(error)
        })
    }
    
    /**
     Evaluate the preconditions on a given coordinator.
     - parameter coordinator: The coordinator whose preconditions need to be evaluated.
     - parameter context: The full context of the navigation.
     - parameter completion: The completion to call when all preconditions have been evaluated.
     - returns: A boolean indicating whether an asynchronous recovery for a precondition is required.
     */
    private func evaluatePreconditions(on coordinator: NavigationPreconditionRequiring, context: NavigationContext,
    completion: @escaping (Error?) -> Void) -> Bool {
        let dispatchGroup = DispatchGroup()
        var preconditionErrors: [Error] = []
        var requiresRecovery: Bool = false
        
        // instantiate an instance of each precondition and evaluate them
        for preconditionType: NavigationPrecondition.Type in type(of: coordinator).preconditions {
            let precondition = preconditionType.init()
            do {
                try precondition.evaluate(context: context)
            } catch {
                // if it's a recovering precondition, set requiredRecovery to try so the caller knows then try to recover
                if let recoveringPrecondition = precondition as? RecoveringNavigationPrecondition {
                    requiresRecovery = true
                    dispatchGroup.enter()
                    recoveringPrecondition.attemptRecovery(context: context, completion: { (recoveryError: Error?) in
                        if let recoveryError = recoveryError {
                            preconditionErrors.append(contentsOf: [error, recoveryError])
                        }
                        dispatchGroup.leave()
                    })
                // otherwise, add an error to the array of errors
                } else {
                    preconditionErrors.append(error)
                }
            }
        }
        
        // call the completion block once all the async tasks are complete
        dispatchGroup.notify(queue: .main) {
            if preconditionErrors.count > 1 {
                let aggregateError = AggregateError(underlyingErrors: preconditionErrors)
                completion(aggregateError)
            } else if preconditionErrors.count == 1 {
                let error = preconditionErrors.first!
                completion(error)
            }
            else {
                completion(nil)
            }
        }
        
        return requiresRecovery
    }
}

/**
 An internal view controller type used as the root view controller of the window. This view controller ensures that the
 status bar style and hidden state are set by its child view controller.
 */
fileprivate class RootViewController: UIViewController, CoordinatedViewController {
    var childViewController: UIViewController?
    
    var baseCoordinator: BaseCoordinator? {
        return nil
    }
    
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

/**
 An internal model type that holds the information of a navigation operation that is stored on a navigator's stack.
 */
fileprivate struct NavStackItem {
    let coordinator: BaseCoordinator
    let presentMethod: PresentMethod
    let canBeNavigatedBackTo: Bool
}

