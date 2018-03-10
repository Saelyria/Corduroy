
import UIKit

/**
 An object that handles navigation between coordinators.
 
 All navigation between coordinators should be handled through a `Navigator` object. The navigator will handle the
 creation of navigation context objects (which hold information like the involved coordinators) and evaluate any
 preconditions that a coordinator may have as a requirement for navigation to it.
 */
public class Navigator {
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
    
    /// The view controller currently being shown.
    public private(set) var currentViewController: UIViewController?
    
    internal var navigationStack: [NavStackItem] = []
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
        precondition(!(firstCoordinator is NavigationPreconditionRequiring.Type), "The first coordinator of the app should not have navigation preconditions.")
        precondition(self.hasStarted == false, "The navigator's `start(onWindow:firstCoordinator:with:)` method was already called.")
        self.hasStarted = true
        
        let firstCoordinator = firstCoordinator.create(with: model, navigator: self)
        let stackItem = NavStackItem(coordinator: firstCoordinator, presentMethod: .addingAsRoot(window: window), canBeNavigatedBackTo: true)
        self.navigationStack.append(stackItem)
        let context = NavigationContext(navigator: self, from: nil, to: firstCoordinator,
                                        present: .addingAsRoot(window: window), dismiss: nil, params: NavigationParameters())
        firstCoordinator.presentViewController(context: context)
        
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
    parameters: NavigationParameters = NavigationParameters()) -> T where T.SetupModel == Void {
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
    parameters: NavigationParameters = NavigationParameters()) -> T {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        precondition(!(coordinator is NavigationPreconditionRequiring.Type), "The specified coordinator has preconditions for navigation that must be checked - use `checkThenGo(to:by:preconditionCompletion:)` instead.")
        
        let coordinator = coordinator.create(with: model, navigator: self)
        let context = NavigationContext(navigator: self, from: self.currentCoordinator, to: coordinator,
                                        present: navMethod, dismiss: nil, params: parameters)
        let stackItem = NavStackItem(coordinator: coordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
        self.navigationStack.append(stackItem)
        coordinator.presentViewController(context: context)
        
        return coordinator
    }
    
    /**
     Navigate to the specified coordinator, evaluating the coordinator's preconditions and rethrowing any precondition
     errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter preconditionCompletion: The block called when the navigator has completed evaluation of preconditions,
        passing in either an error or the created coordinator. Optional.
     */
    public func checkThenGo<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod,
    parameters: NavigationParameters = NavigationParameters(), preconditionCompletion: ((Error?, T?) -> Void)?) where T.SetupModel == Void {
        self.checkThenGo(to: coordinator, by: navMethod, with: (), preconditionCompletion: preconditionCompletion)
    }
    
    /**
     Navigate to the specified coordinator with the given setup model, evaluating the coordinator's preconditions and
     rethrowing any precondition errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter preconditionCompletion: The block called when the navigator has completed evaluation of preconditions,
        passing in either an error or the created coordinator. Optional.
     */
    public func checkThenGo<T: Coordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod,
    with model: T.SetupModel, parameters: NavigationParameters = NavigationParameters(), preconditionCompletion: ((Error?, T?) -> Void)?) {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")

        let coordinator = coordinator.create(with: model, navigator: self)
        let context = NavigationContext(navigator: self, from: self.currentCoordinator, to: coordinator,
                                        present: navMethod, dismiss: nil, params: parameters)
        let requiresRecovery = self.evaluatePreconditions(on: coordinator, context: context, completion: { (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    preconditionCompletion?(error, nil)
                } else {
                    let stackItem = NavStackItem(coordinator: coordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
                    self.navigationStack.append(stackItem)
                    
                    preconditionCompletion?(nil, coordinator)
                    coordinator.presentViewController(context: context)
                }
            }
        })
        
        if requiresRecovery {
            self.currentCoordinator.onPreconditionRecoveryStarted()
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
    parameters: NavigationParameters = NavigationParameters(), flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) -> T where T.SetupModel == Void {
        return self.go(to: flowCoordinator, by: navMethod, with: (), flowCompletion: flowCompletion)
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
        precondition(!(flowCoordinator is NavigationPreconditionRequiring.Type), "The specified coordinator has preconditions for navigation that must be checked - use `checkThenGo(to:by:preconditionCompletion:flowCompletion:)` instead.")
        
        let flowCoordinator = flowCoordinator.create(with: model, navigator: self)
        let context = NavigationContext(navigator: self, from: self.currentCoordinator, to: flowCoordinator,
                                        present: navMethod, dismiss: nil, params: parameters)
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
     - parameter preconditionCompletion: The block called when the navigator has completed evaluation of preconditions,
        passing in either an error or the created coordinator. Optional.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
    public func checkThenGo<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod,
    parameters: NavigationParameters = NavigationParameters(), preconditionCompletion: ((Error?, T?) -> Void)?,
    flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) where T.SetupModel == Void {
        self.checkThenGo(to: flowCoordinatorType, by: navMethod, with: (), preconditionCompletion: preconditionCompletion!, flowCompletion: flowCompletion)
    }
	
    /**
     Navigate to the specified flow coordinator with the given setup model, evaluating the coordinator's preconditions
     and rethrowing any precondition errors that arise.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter preconditionCompletion: The block called when the navigator has completed evaluation of preconditions,
        passing in either an error or the created coordinator. Optional.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
	public func checkThenGo<T: FlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod,
    with model: T.SetupModel, parameters: NavigationParameters = NavigationParameters(), preconditionCompletion: ((Error?, T?) -> Void)?,
    flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        
        let flowCoordinator = flowCoordinatorType.create(with: model, navigator: self)
        let context = NavigationContext(navigator: self, from: self.currentCoordinator, to: flowCoordinator,
                                        present: navMethod, dismiss: nil, params: parameters)
        let requiresRecovery = self.evaluatePreconditions(on: flowCoordinator, context: context, completion: { (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    preconditionCompletion?(error, nil)
                } else {
                    let stackItem = NavStackItem(coordinator: flowCoordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
                    self.navigationStack.append(stackItem)
                    preconditionCompletion?(nil, flowCoordinator)
                    flowCoordinator.presentFirstViewController(context: context, flowCompletion: flowCompletion)
                }
            }
        })
        
        if requiresRecovery {
            self.currentCoordinator.onPreconditionRecoveryStarted()
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
        
        // get the coordinators to be removed in order from the end and call their `onDismissal(context:)` methods
        guard let coordinatorIndex = self.navigationStack.index(where: { $0.coordinator === coordinator }) else { return }
        for index in stride(from: self.navigationStack.count-1, to: coordinatorIndex, by: -1) {
            let navStackItem = self.navigationStack[index]

            let coordinatorToRemove: BaseCoordinator = navStackItem.coordinator
            let params: NavigationParameters
            if index == coordinatorIndex+1 {
                params =  parameters
            } else {
                params = NavigationParameters(animateTransition: false)
            }
            
            for (viewController, _) in navStackItem.viewControllersAndPresentMethods {
                navStackItem.coordinator.dismiss(viewController, parameters: params)
            }

            coordinatorToRemove.onDismissal()
            self.navigationStack.remove(at: index)
        }
        
        self.shouldIgnoreNavControllerPopRequests = false
    }
    
    // MARK: CoordinatedViewController methods
    
    internal func navigationControllerDidPopViewControllers(_ viewControllers: [UIViewController]) {
        if self.shouldIgnoreNavControllerPopRequests {
            return
        }
        
        for index in stride(from: viewControllers.count-1, through: 0, by: -1) {
            let vc: UIViewController = viewControllers[index]
            guard vc === self.navigationStack.last!.viewControllersAndPresentMethods.last!.vc else {
                fatalError("Wrong")
            }
            self.navigationStack.last!.viewControllersAndPresentMethods.removeLast()
            if self.navigationStack.last!.viewControllersAndPresentMethods.isEmpty {
                let removedCoordinator: BaseCoordinator = self.navigationStack.last!.coordinator
                self.navigationStack.removeLast()
                removedCoordinator.onDismissal()
            }
        }
        
        self.currentViewController = self.navigationStack.last!.viewControllersAndPresentMethods.last!.vc
    }
    
    internal func viewControllerDidAppear(_ viewController: UIViewController, coordinator: BaseCoordinator, presentMethod: PresentMethod) {
        guard coordinator === self.currentCoordinator else {
            fatalError("Misalignment of view controllers and coordinators on the nav stack.")
        }
        
        self.navigationStack.last!.viewControllersAndPresentMethods.append((viewController, presentMethod))
        self.currentViewController = viewController
    }
    
    internal func viewControllerDidDisappear(_ viewController: UIViewController, coordinator: BaseCoordinator) {
        if self.shouldIgnoreNavControllerPopRequests {
            return
        }
        
        guard coordinator === self.currentCoordinator else {
            fatalError("Misalignment of view controllers and coordinators on the nav stack.")
        }
        self.navigationStack.last!.viewControllersAndPresentMethods.removeLast()
        if self.navigationStack.last!.viewControllersAndPresentMethods.isEmpty {
            self.navigationStack.removeLast()
        }
        self.currentViewController = self.navigationStack.last!.viewControllersAndPresentMethods.last!.vc
    }
    
    // MARK: Precondition evaluation
    
    internal func navigateForFlowRecoveringPrecondition<T: FlowRecoveringNavigationPrecondition>(_ precondition: T,
    completion: @escaping (Bool) -> Void) {
        guard !(T.RecoveringFlowCoordinator.self is NavigationPreconditionRequiring.Type) else {
            fatalError("The flow coordinator for a flow recovering precondition must not require preconditions of its own.")
        }
        
        self.go(to: T.RecoveringFlowCoordinator.self, by: precondition.recoveryCoordinatorPresentMethod, flowCompletion: { (error: Error?, _) in
            let succeeded: Bool = error == nil
            completion(succeeded)
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
                // if it's a recovering precondition, set requiredRecovery so the caller knows then try to recover
                if let recoveringPrecondition = precondition as? RecoveringNavigationPrecondition {
                    requiresRecovery = true
                    dispatchGroup.enter()
                    recoveringPrecondition.attemptRecovery(context: context, completion: { (recovered: Bool) in
                        if !recovered {
                            preconditionErrors.append(error)
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
internal class NavStackItem {
    public let coordinator: BaseCoordinator
    public let presentMethod: PresentMethod
    public let canBeNavigatedBackTo: Bool
    public var viewControllersAndPresentMethods: [(vc: UIViewController, presentMethod: PresentMethod)] = []
    
    public init(coordinator: BaseCoordinator, presentMethod: PresentMethod, canBeNavigatedBackTo: Bool) {
        self.coordinator = coordinator
        self.presentMethod = presentMethod
        self.canBeNavigatedBackTo = canBeNavigatedBackTo
    }
}

