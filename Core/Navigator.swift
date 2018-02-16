
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
        /// Will be `nil` if this is the first coordinator navigation.
        public let currentViewController: UIViewController?
        /// The coordinator being navigated away from. Will be `nil` if this is the first coordinator navigation.
        public let fromCoordinator: BaseCoordinator?
        /// The coordinator being navigated to.
        public let toCoordinator: BaseCoordinator
        /// The presentation method requested to be used to present the to coordinator's first view controller. Will be
        /// `nil` if the navigation is a dismissal.
        public let requestedPresentMethod: PresentMethod?
        /// The dissmissal method requested to be used to dismiss the coordinator's top view controller Will be `nil` if
        /// the navigation is a presentation.
        public let requestedDismissMethod: DismissMethod?
        /// Other parameters for the navigation, such as the requested modal presentation style.
        public let parameters: NavigationParameters
        /// The navigator handling the navigation.
        public let navigator: Navigator
        
        internal init(navigator: Navigator, viewController: UIViewController?, from: BaseCoordinator?,
                      to: BaseCoordinator, present: PresentMethod?, dismiss: DismissMethod?, params: NavigationParameters) {
            self.navigator = navigator
            self.currentViewController = viewController
            self.fromCoordinator = from
            self.toCoordinator = to
            self.requestedPresentMethod = present
            self.requestedDismissMethod = dismiss
            self.parameters = params
        }
    }
    
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
    public func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T.Type) -> T where T.SetupModel == Nothing {
        return self.start(onWindow: window, firstCoordinator: firstCoordinator, with: nil)
    }
    
    /**
     Start the navigator with the first coordinator.
     - parameter window: The root window that view controllers should be presented on.
     - parameter firstCoordinator: The type of coordinator to start the app from.
     - parameter model: A model of the given coordinator's setup model type.
     */
    @discardableResult
    public func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T.Type, with model: T.SetupModel) -> T {
        precondition(!(firstCoordinator is NavigationPreconditionRequiring.Type), "The first coordinator of the app should not have navigation preconditions.")
        precondition(self.hasStarted == false, "The navigator's `start(onWindow:firstCoordinator:with:)` method was already called.")
        self.hasStarted = true
        
        let firstCoordinator = firstCoordinator.create(with: model, navigator: self)
        let stackItem = NavStackItem(coordinator: firstCoordinator, presentMethod: .addingAsRoot(window: window), canBeNavigatedBackTo: true)
        self.navigationStack.append(stackItem)
        let context = NavigationContext(navigator: self, viewController: nil, from: nil,
            to: firstCoordinator, present: .addingAsRoot(window: window), dismiss: nil, params: NavigationParameters())
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
    public func go<T: Coordinator>(to coordinator: T.Type, by navMethod: PresentMethod,
    parameters: NavigationParameters = NavigationParameters()) -> T where T.SetupModel == Nothing {
        return self.go(to: coordinator, by: navMethod, with: nil, parameters: parameters)
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
    parameters: NavigationParameters = NavigationParameters()) -> T {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        precondition(!(coordinator is NavigationPreconditionRequiring.Type), "The specified coordinator has preconditions for navigation that must be checked - use `evaluatePreconditionsAndGo(to:by:evaluationCompletion:)` instead.")
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let coordinator = coordinator.create(with: model, navigator: self)
        let context = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                        to: coordinator, present: navMethod, dismiss: nil, params: parameters)
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
    parameters: NavigationParameters = NavigationParameters(), evaluationCompletion: @escaping (Error?, T?) -> Void) where T.SetupModel == Nothing {
        self.evaluatePreconditionsAndGo(to: coordinator, by: navMethod, with: nil, evaluationCompletion: evaluationCompletion)
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
    with model: T.SetupModel, parameters: NavigationParameters = NavigationParameters(), evaluationCompletion: @escaping (Error?, T?) -> Void) {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let coordinator = coordinator.create(with: model, navigator: self)
        let context = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                        to: coordinator, present: navMethod, dismiss: nil, params: parameters)
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
            self.currentCoordinator.onRecoveringPreconditionEvaluationDidStart()
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
    @discardableResult
    public func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod,
    parameters: NavigationParameters = NavigationParameters(), flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) -> T where T.SetupModel == Nothing {
        return self.go(to: flowCoordinator, by: navMethod, with: nil, flowCompletion: flowCompletion)
    }
    
    /**
     Navigate to the specified flow coordinator with the given setup model.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
    @discardableResult
    public func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: NavigationParameters = NavigationParameters(), flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) -> T {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        precondition(!(flowCoordinator is NavigationPreconditionRequiring.Type), "The specified coordinator has preconditions for navigation that must be checked - use `evaluatePreconditionsAndGo(to:by:evaluationCompletion:)` instead.")
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let flowCoordinator = flowCoordinator.create(with: model, navigator: self)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                                           to: flowCoordinator, present: navMethod, dismiss: nil, params: parameters)
        let stackItem = NavStackItem(coordinator: flowCoordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
        self.navigationStack.append(stackItem)
        flowCoordinator.presentFirstViewController(context: context, flowCompletion: flowCompletion)
        
        return flowCoordinator
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
    parameters: NavigationParameters = NavigationParameters(), evaluationCompletion: @escaping (Error?, T?) -> Void,
    flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) where T.SetupModel == Nothing {
        self.evaluatePreconditionsAndGo(to: flowCoordinatorType, by: navMethod, with: nil, evaluationCompletion: evaluationCompletion, flowCompletion: flowCompletion)
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
    with model: T.SetupModel, parameters: NavigationParameters = NavigationParameters(), evaluationCompletion: @escaping (Error?, T?) -> Void,
    flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        guard let viewController = self.currentCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let flowCoordinator = flowCoordinatorType.create(with: model, navigator: self)
        let context: NavigationContext = NavigationContext(navigator: self, viewController: viewController, from: self.currentCoordinator,
                                                           to: flowCoordinator, present: navMethod, dismiss: nil, params: parameters)
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
            self.currentCoordinator.onRecoveringPreconditionEvaluationDidStart()
        }
    }
    
    // MARK: Backwards navigation methods
    
    /**
     Navigate back to the previous coordinator.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack(parameters: NavigationParameters = NavigationParameters()) {
        guard let previousCoordinator = self.previousCoordinator else { return }
        self.goBack(to: previousCoordinator)
    }
    
    /**
     Navigate back to the last coordinator of the specified coordinator type.
     - parameter coordinatorType: The coordinator type to navigate back to.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack<T: BaseCoordinator>(toLast coordinatorType: T.Type, parameters: NavigationParameters = NavigationParameters()) {
        let coordinator = self.coordinators.reversed().first(where: { (coordinator) -> Bool in
            return coordinator is T && coordinator !== self.coordinators.last
        })
        if let coordinator = coordinator {
            self.goBack(to: coordinator, parameters: parameters)
        }
    }
    
    /**
     Navigate back to the specified coordinator.
     - parameter coordinator: The coordinator to navigate back to.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack(to coordinator: BaseCoordinator, parameters: NavigationParameters = NavigationParameters()) {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        
        // start ignoring calls to 'coordinatedNavControllerDidPopCoordinators'. See comment on `shouldIgnoreNavControllerPopRequests`'s declaration.
        self.shouldIgnoreNavControllerPopRequests = true
        
        // get the coordinators to be removed in order from the end and call their `dismiss(context:)` methods
        guard let coordinatorIndex = self.coordinators.index(where: { $0 === coordinator }) else { return }
        for index in stride(from: self.navigationStack.count-1, to: coordinatorIndex, by: -1) {
            let navStackItem = self.navigationStack[index]
            guard let viewController = navStackItem.coordinator.currentViewController else {
                fatalError("The currentViewController on a \(type(of: navStackItem.coordinator)) was nil during navigation back to it.")
            }
            let dismissMethod = navStackItem.presentMethod.inverseDismissMethod
            let coordinatorToRemove: BaseCoordinator = navStackItem.coordinator
            let coordinatorBeforeRemovedCoordinator: BaseCoordinator = self.coordinators[index-1]
            let params: NavigationParameters
            if index == coordinatorIndex+1 {
                params = parameters
            } else {
                params = NavigationParameters(animateTransition: false)
            }
            let context = NavigationContext(navigator: self, viewController: viewController, from: coordinatorToRemove,
                                            to: coordinatorBeforeRemovedCoordinator, present: nil, dismiss: dismissMethod, params: params)
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
 An internal model type that holds the information of a navigation operation that is stored on a navigator's stack.
 */
fileprivate struct NavStackItem {
    let coordinator: BaseCoordinator
    let presentMethod: PresentMethod
    let canBeNavigatedBackTo: Bool
}

