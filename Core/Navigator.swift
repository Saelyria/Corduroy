
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
    public var currentViewController: UIViewController? {
        return self.navigationStack.last?.viewControllersAndPresentMethods.last?.vc
    }
    
    /// The application's tab bar controller, if the navigator was started with one.
    public private(set) var tabBarController: UITabBarController?
    
    /// The active navigation stack. If the app is using a tab bar controller, this will be the stack on the active
    /// tab.
    public var navigationStack: [NavStackItem] {
        return self.tabStack[self.selectedTab]
    }
    /// The stack of coordinators for each tab of the tab controller.
    private var tabStack: [[NavStackItem]] = []
    private var selectedTab: Int {
        return self.tabBarController?.selectedIndex ?? 0
    }
    
    private var hasStarted: Bool = false
    
    // There's no reliable way to determine whether a back navigation from a UINavigationController was started by it
    // being explicitly told to do it vs. the back button of its nav bar being pressed, so we need this flag to
    // determine whether or not we should ignore calls to our `coordinatedNavControllerDidPopCoordinators` method so we
    // don't end up with duplicate calls.
    private var shouldIgnoreNavControllerPopRequests: Bool = false
    
    /// Initialize a new Navigator object.
    public init() { }
    
    /**
     Start the navigator with tab coordinators for the given tab bar controller.
     - parameter window: The root window that view controllers should be presented on.
     - parameter tabCoordinators: The coordinators for the root view controllers of each tab.
     - parameter tabBarController: The app's tab bar controller. If nil is passed in, the navigator will create a basic
        tab bar controller.
     */
    @discardableResult
    public func start(onWindow window: UIWindow, tabCoordinators: [TabCoordinator.Type], tabBarController: UITabBarController? = nil) -> TabCoordinator {
        precondition(self.hasStarted == false, "One of the navigator's `start` methods was already called.")
        if let tabBarController = tabBarController {
            self.tabBarController = tabBarController
        } else {
            self.tabBarController = UITabBarController()
        }
        self.hasStarted = true
        
        var viewControllers: [UIViewController] = []
        var tabIndex: Int = 0
        for coordinator in tabCoordinators {
            let coordinator = coordinator.create(navigator: self)
            let vc = coordinator.createViewController()
            viewControllers.append(vc)
            let navStackItem = NavStackItem(coordinator: coordinator, presentMethod: .switchingToTab, canBeNavigatedBackTo: true)
            self.tabStack[tabIndex] = [navStackItem]
            tabIndex = tabIndex + 1
        }
        self.tabBarController?.viewControllers = viewControllers
        return self.tabStack[self.selectedTab][0].coordinator as! TabCoordinator
    }
    
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
        precondition(self.hasStarted == false, "One of the navigator's `start` methods was already called.")
        self.hasStarted = true
        
        let firstCoordinator = firstCoordinator.create(with: model, navigator: self)
        let stackItem = NavStackItem(coordinator: firstCoordinator, presentMethod: .addingAsRoot(window: window), canBeNavigatedBackTo: true)
        self.tabStack.append([stackItem])
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
    parameters: NavigationParameters = NavigationParameters()) -> NavigationResult<T> where T.SetupModel == Void {
        return self.go(to: coordinator, by: navMethod, with: (), parameters: parameters)
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
    public func go<T: Coordinator>(to coordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: NavigationParameters = NavigationParameters()) -> NavigationResult<T> {
        return self.go(to: coordinator, by: navMethod, with: model, parameters: parameters, presentBlock: { coordinator, context in
            coordinator.presentViewController(context: context)
        })
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
    public func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod, parameters: NavigationParameters = NavigationParameters(),
    flowCompletion: @escaping (Error?, T.FlowResult?) -> Void) -> NavigationResult<T> where T.SetupModel == Void {
        return self.go(to: flowCoordinator, by: navMethod, with: (), flowCompletion: flowCompletion)
    }
    
    /**
     Navigate to the specified flow coordinator with the given setup model.
     - parameter flowCoordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
    @discardableResult
    public func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: NavigationParameters = NavigationParameters(), flowCompletion: @escaping (Error?, T.FlowResult?) -> Void) -> NavigationResult<T> {
        return self.go(to: flowCoordinator, by: navMethod, with: model, parameters: parameters, presentBlock: { flowCoordinator, context in
            flowCoordinator.presentFirstViewController(context: context, flowCompletion: flowCompletion)
        })
    }
    
    private func go<T: BaseCoordinator & SetupModelRequiring>(to coordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: NavigationParameters, presentBlock: @escaping (T, NavigationContext) -> Void) -> NavigationResult<T> {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        
        let coordinator = T.create(with: model, navigator: self)
        
        // Create the coordinator, context, and nav result. When the nav result is dealloc'd (i.e. goes out of scope),
        // it will call the passed-in 'present' block to tell the coordinator to finally present its view controller.
        // If there were no preconditions / event bindings on it, it will dealloc at the end of this method. If there
        // were bindings, it will dealloc at the end of the scope in which the 'go(to:)' method was called (as long as a
        // reference to it was not held). If there were preconditions, it will go out of scope after the 'completion' on
        // 'evaluatePreconditions(on:context:completion:)' finishes.
        let context = NavigationContext(navigator: self, from: self.currentCoordinator, to: coordinator,
                                        present: navMethod, dismiss: nil, params: parameters)
        let navResult = NavigationResult<T>(completionHandler: {
            if Thread.isMainThread {
                presentBlock(coordinator, context)
            } else {
                DispatchQueue.main.async {
                    presentBlock(coordinator, context)
                }
            }
        })
        
        // if the coordinator has preconditions, start evaluating them
        if let preconCoordinator = coordinator as? NavigationPreconditionRequiring {
            let recoveryMethods = self.evaluatePreconditions(on: preconCoordinator, context: context, completion: { [navResult, unowned self] (error: Error?) in
                let handler = {
                    if let error = error {
                        navResult.preconditonError = error
                    } else {
                        let stackItem = NavStackItem(coordinator: coordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
                        self.tabStack[self.selectedTab].append(stackItem)
                        navResult.coordinator = coordinator
                    }
                }
                
                if Thread.isMainThread {
                    handler()
                } else {
                    DispatchQueue.main.async {
                        handler()
                    }
                }
            })
            
            if recoveryMethods.contains(.flowCoordinator) {
                navResult.flowRecoveryHasStarted = true
            } else if recoveryMethods.contains(.asyncTask) {
                navResult.recoveringPreconditionsHaveStarted = true
            }
        }
        
        // otherwise, just add the coordinator to the stack and let the nav result object go out of scope to call present
        else {
            let stackItem = NavStackItem(coordinator: coordinator, presentMethod: navMethod, canBeNavigatedBackTo: true)
            self.tabStack[self.selectedTab].append(stackItem)
            navResult.coordinator = coordinator
        }
        
        return navResult
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
            self.tabStack[self.selectedTab].remove(at: index)
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
                self.tabStack[self.selectedTab].removeLast()
                removedCoordinator.onDismissal()
            }
        }
    }
    
    internal func viewControllerDidAppear(_ viewController: UIViewController, coordinator: BaseCoordinator, presentMethod: PresentMethod) {
        guard coordinator === self.currentCoordinator else {
            fatalError("Misalignment of view controllers and coordinators on the nav stack.")
        }

        if let navController = viewController as? UINavigationController, let topVC = navController.topViewController {
            self.navigationStack.last!.viewControllersAndPresentMethods.append((topVC, presentMethod))
        } else {
            self.navigationStack.last!.viewControllersAndPresentMethods.append((viewController, presentMethod))
        }
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
            self.tabStack[self.selectedTab].removeLast()
        }
    }
    
    // MARK: Precondition evaluation
    
    /**
     Evaluate the preconditions on a given coordinator.
     - parameter coordinator: The coordinator whose preconditions need to be evaluated.
     - parameter context: The full context of the navigation.
     - parameter completion: The completion to call when all preconditions have been evaluated.
     - returns: A boolean indicating whether an asynchronous recovery for a precondition is required.
     */
    private func evaluatePreconditions(on coordinator: NavigationPreconditionRequiring, context: NavigationContext,
    completion: @escaping (Error?) -> Void) -> [PreconditionRecoveryMethod] {
        
        let dispatchGroup = DispatchGroup()
        var preconditionErrors: [Error] = []
        var recoveryMethods: Set<PreconditionRecoveryMethod> = []
        
        // instantiate an instance of each precondition and evaluate them
        for preconditionType: NavigationPrecondition.Type in type(of: coordinator).preconditions {
            let precondition = preconditionType.init()
            do {
                try precondition.evaluate(context: context)
            } catch {
                // if it's a recovering precondition, set requiredRecovery so the caller knows then try to recover
                if let recoveringPrecondition = precondition as? RecoveringNavigationPrecondition {
                    dispatchGroup.enter()
                    let recoveryMethod = recoveringPrecondition.attemptRecovery(context: context, completion: { (recovered: Bool) in
                        if !recovered {
                            preconditionErrors.append(error)
                        }
                        dispatchGroup.leave()
                    })
                    recoveryMethods.insert(recoveryMethod)
                }
                // otherwise, add the error to the array of errors
                else {
                    preconditionErrors.append(error)
                }
            }
        }
        
        if (recoveryMethods.contains(.flowCoordinator) && recoveryMethods.contains(.asyncTask)) {
            print("WARNING: Preconditions for a coordinator having both 'asynchronous task' and 'flow coordinator' recovery methods is not supported; unexpected results may occur.")
        }
        
        // call the completion block once all the async tasks are complete
        dispatchGroup.notify(queue: .main) {
            if preconditionErrors.count >= 1 {
                let aggregateError = AggregateError(underlyingErrors: preconditionErrors)
                completion(aggregateError)
            } else {
                completion(nil)
            }
        }
        
        return Array(recoveryMethods)
    }
}
