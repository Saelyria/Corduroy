
import UIKit

/**
 Describes an object (a coordinator specifically) that manages a subset of the app's navigation stack.
 
 'Sub-navigating' coordinators are special-use coordinators/view controllers like tab bar controllers that manage a set
 of coordinators/view controllers themselves. When the navigator detects that its current top coordinator is a 'sub-
 navigating' coordinator, it will attempt to forward all navigations to it while the sub-navigating coordinator reports
 that it can manage the navigation via its `canManager(navigationDescribedBy:)` method.
 */
internal protocol SubNavigating {
    /// The navigations that this coordinator managed on behalf of the navigator.
    var navigationStack: [Navigation] { get }
    
    func canManage(navigationDescribedBy context: NavigationContext) -> Bool
    
    func add(navigation: Navigation)
}


/**
 An object that handles navigation between coordinators.
 
 All navigation between coordinators should be handled through a `Navigator` object. The navigator will handle the
 creation of navigation context objects (which hold information like the involved coordinators) and evaluate any
 preconditions that a coordinator may have as a requirement for navigation to it.
 */
open class Navigator {
    /// Whether Corduroy should use method swizzling for navigation controller popping observation. If this is set to
    /// false, all navigation controllers in your application must be or subclass `CoordinatedNavigationController`.
    static var useSwizzling: Bool = true
    
    /// The coordinator coordinating the currently shown view controller.
    public var currentCoordinator: AnyCoordinator {
        return self.coordinators.last!
    }
    
    /// The current stack of coordinators in historical order of their navigation.
    public var coordinators: [AnyCoordinator] {
        return self.navigationStack.map({ $0.coordinator })
    }
    private var previousCoordinator: AnyCoordinator? {
        guard self.coordinators.count >= 2 else { return nil }
        return self.coordinators[self.coordinators.count-2]
    }
    
    /// The view controller currently being shown.
    public var currentViewController: UIViewController? {
        for i in stride(from: self.navigationStack.count-1, through: 0, by: -1) {
            let stackItem = self.navigationStack[i]
            if let vc = stackItem.viewControllersAndPresentMethods.last?.vc {
                return vc
            }
        }
        return nil
    }
    
    public private(set) var window: UIWindow!

    /// The series of navigations that has led to the currently active coordinator.
    public var navigationStack: [Navigation] {
        var navigations: [Navigation] = []
        for navigation in self.navigatorManagedNavigationStack {
            navigations.append(navigation)
            if let subNavigatingCoordinator = navigation.coordinator as? SubNavigating {
                navigations.append(contentsOf: subNavigatingCoordinator.navigationStack)
            }
        }
        return navigations
    }
    /// The navigations and their coordinators managed directly by this navigator. This array does not include
    /// 'sub-navigated' navigation stacks managed by a coordinator conforming to `SubNavigating`.
    private var navigatorManagedNavigationStack: [Navigation] = []
    private var hasStarted: Bool = false
    
    // There's no reliable way to determine whether a back navigation from a UINavigationController was started by it
    // being explicitly told to do it vs. the back button of its nav bar being pressed, so we need this flag to
    // determine whether or not we should ignore calls to our `coordinatedNavControllerDidPopCoordinators` method so we
    // don't end up with duplicate calls.
    private var shouldIgnoreNavControllerPopRequests: Bool = false
    
    private static var hasSwizzled: Bool = false
    
    /// Instantiate a new navigator.
    public required init() {
        if Navigator.useSwizzling, Navigator.hasSwizzled == false {
            Navigator.hasSwizzled = true
            swizzle(c: UINavigationController.self,
                    original: #selector(UINavigationController.popViewController(animated:)),
                    swizzled: #selector(UINavigationController.corduroy_popViewController(animated:)))
            
            swizzle(c: UINavigationController.self,
                    original: #selector(UINavigationController.popToRootViewController(animated:)),
                    swizzled: #selector(UINavigationController.corduroy_popToRootViewController(animated:)))
            
            swizzle(c: UINavigationController.self,
                    original: #selector(UINavigationController.popToViewController(_:animated:)),
                    swizzled: #selector(UINavigationController.corduroy_popToViewController(_:animated:)))
        }
    }
    
    /**
     Start the navigator with the first coordinator.
     - parameter window: The root window that view controllers should be presented on.
     - parameter firstCoordinator: The type of coordinator to start the app from.
     */
    @discardableResult
    open func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T.Type) -> T where T.SetupModel == Void {
        return self.start(onWindow: window, firstCoordinator: firstCoordinator, with: ())
    }
    
    /**
     Start the navigator with the first coordinator.
     - parameter window: The root window that view controllers should be presented on.
     - parameter firstCoordinator: The type of coordinator to start the app from.
     - parameter model: A model of the given coordinator's setup model type.
     */
    @discardableResult
    open func start<T: Coordinator>(onWindow window: UIWindow, firstCoordinator: T.Type, with model: T.SetupModel) -> T {
        precondition(!(firstCoordinator is NavigationPreconditionRequiring.Type), "The first coordinator of the app should not have navigation preconditions.")
        precondition(self.hasStarted == false, "One of the navigator's `start` methods was already called.")
        
        self.hasStarted = true
        self.window = window
        
        let firstCoordinator = firstCoordinator.create(with: model, navigator: self)
        let stackItem = Navigation(coordinator: firstCoordinator, presentMethod: .addingAsRoot, parentCoordinator: nil)
        self.navigatorManagedNavigationStack.append(stackItem)
        let context = NavigationContext(navigator: self, from: firstCoordinator, to: firstCoordinator, by: .addingAsRoot, params: .defaults)
        firstCoordinator.start(context: context)
        firstCoordinator.didBecomeActive(context: context)
        
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
    open func go<T: Coordinator>(to coordinator: T.Type, by navMethod: PresentMethod,
    parameters: Set<NavigationParameter> = .defaults) -> NavigationResult<T> where T.SetupModel == Void {
        return self.go(to: coordinator, by: navMethod, with: (), parameters: parameters)
    }
    
    /**
     Navigate to the specified coordinator with the given setup model.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    open func go<T: Coordinator>(to coordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: Set<NavigationParameter> = .defaults) -> NavigationResult<T> {
        return self.go(to: coordinator, by: navMethod, with: model, parameters: parameters, presentBlock: { coordinator, context in
            coordinator.start(context: context)
            coordinator.didBecomeActive(context: context)
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
    open func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod, parameters: Set<NavigationParameter> = .defaults,
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
    open func go<T: FlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: Set<NavigationParameter> = .defaults, flowCompletion: @escaping (Error?, T.FlowResult?) -> Void) -> NavigationResult<T> {
        return self.go(to: flowCoordinator, by: navMethod, with: model, parameters: parameters, presentBlock: { flowCoordinator, context in
            flowCoordinator.start(context: context, flowCompletion: flowCompletion)
            flowCoordinator.didBecomeActive(context: context)
        })
    }
    
    private func go<T: AnyCoordinator & SetupModelRequiring>(to coordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: Set<NavigationParameter>, presentBlock: @escaping (T, NavigationContext) -> Void) -> NavigationResult<T> {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        
        let coordinator = T.create(with: model, navigator: self)
        
        // Create the coordinator, context, and nav result. When the nav result is dealloc'd (i.e. goes out of scope),
        // it will call the passed-in 'present' block to tell the coordinator to finally present its view controller.
        // If there were no preconditions / event bindings on it, it will dealloc at the end of this method. If there
        // were bindings, it will dealloc at the end of the scope in which the 'go(to:)' method was called (as long as a
        // reference to it was not held). If there were preconditions, it will go out of scope after the 'completion' on
        // 'evaluatePreconditions(on:context:completion:)' finishes.
        let context = NavigationContext(navigator: self, from: self.currentCoordinator, to: coordinator, by: navMethod, params: parameters)
        let navResult = NavigationResult<T>(onDealloc: {
            if Thread.isMainThread {
                presentBlock(coordinator, context)
            } else {
                DispatchQueue.main.async {
                    presentBlock(coordinator, context)
                }
            }
        })
        
        // if the coordinator has preconditions, start evaluating them. Make sure the 'evaluate preconditions' completion
        // block captures the nav result object so it's not deallocated
        if let preconCoordinator = coordinator as? NavigationPreconditionRequiring {
            let recoveryMethods = self.evaluatePreconditions(on: preconCoordinator, context: context, completion: { [navResult, unowned self] (error: Error?) in
                if let error = error {
                    navResult.preconditonError = error
                } else {
                    self.add(coordinator: coordinator, presentMethod: navMethod, context: context)
                    navResult.coordinator = coordinator
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
            self.add(coordinator: coordinator, presentMethod: navMethod, context: context)
            navResult.coordinator = coordinator
        }
        
        return navResult
    }
    
    private func add(coordinator: AnyCoordinator, presentMethod: PresentMethod, context: NavigationContext) {
        if let subNavigatingCoordinator = self.navigationStack.last?.parentCoordinator,
        subNavigatingCoordinator.canManage(navigationDescribedBy: context) {
            let navigation = Navigation(coordinator: coordinator, presentMethod: presentMethod, parentCoordinator: subNavigatingCoordinator)
            subNavigatingCoordinator.add(navigation: navigation)
        } else {
            let navigation = Navigation(coordinator: coordinator, presentMethod: presentMethod, parentCoordinator: nil)
            self.navigatorManagedNavigationStack.append(navigation)
        }
    }
    
    // MARK: Tab bar navigation methods
    
    /**
     Switch to the tab managed by the given `TabBarEmbeddable`.
    */
    open func `switch`<T: TabBarEmbeddable>(toTabFor TabBarEmbeddable: T.Type, on tabBarCoordinator: TabBarCoordinator? = nil) {
        var _tabBarCoordinator: TabBarCoordinator? = tabBarCoordinator
        if _tabBarCoordinator == nil {
            for i in stride(from: self.navigatorManagedNavigationStack.count-1, through: 0, by: -1) {
                let stackItem = self.navigatorManagedNavigationStack[i]
                if let lastTabBarCoordinator = stackItem.coordinator as? TabBarCoordinator,
                lastTabBarCoordinator.tabbedCoordinators.contains(where: { $0 is T }) {
                    _tabBarCoordinator = lastTabBarCoordinator
                    break
                }
            }
        }
        
        guard _tabBarCoordinator != nil else {
            print("WARNING: the navigator was asked to switch to a `TabBarEmbeddable`, but no `TabBarCoordinator` in its stack could")
            return
        }
        
        _tabBarCoordinator?.switch(to: TabBarEmbeddable)
    }
    
    // MARK: Backwards navigation methods
    
    /**
     Navigate back to the previous coordinator.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    open func goBack(parameters: Set<NavigationParameter> = .defaults) {
        guard let previousCoordinator = self.previousCoordinator else { return }
        self.goBack(to: previousCoordinator)
    }
    
    /**
     Navigate back to the last coordinator of the specified coordinator type.
     - parameter coordinatorType: The coordinator type to navigate back to.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    open func goBack<T: AnyCoordinator>(toLast coordinatorType: T.Type, parameters: Set<NavigationParameter> = .defaults) {
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
    open func goBack(to coordinator: AnyCoordinator, parameters: Set<NavigationParameter> = .defaults) {
        precondition(self.hasStarted, "The navigator hasn't been started - call `start(onWindow:firstCoordinator:with:)` first.")
        
        // start ignoring calls to 'coordinatedNavControllerDidPopCoordinators'. See comment on `shouldIgnoreNavControllerPopRequests`'s declaration.
        self.shouldIgnoreNavControllerPopRequests = true
        
        // get the coordinators to be removed in order from the end and call their `onDismissal(context:)` methods
        guard let coordinatorIndex = self.navigationStack.firstIndex(where: { $0.coordinator === coordinator }) else { return }
        for index in stride(from: self.navigationStack.count-1, to: coordinatorIndex, by: -1) {
            let navStackItem = self.navigationStack[index]

            let coordinatorToRemove: AnyCoordinator = navStackItem.coordinator
            
            // only animate the last coordinator to be dismissed
            let params: Set<NavigationParameter>
            if index == coordinatorIndex+1 {
                params =  parameters
            } else {
                params = parameters.replacingValues(in: [.shouldAnimateTransition(false)])
            }
            
            for (i, viewController) in coordinatorToRemove.viewControllers.reversed().enumerated() {
                // only animate the last view controller to be dismissed
                var vcParams: Set<NavigationParameter> = params
                if i < coordinatorToRemove.viewControllers.count - 1 {
                    vcParams = .noAnimation
                }
                coordinatorToRemove.dismiss(viewController, parameters: vcParams)
            }
            
            let previousCoordinator: AnyCoordinator
            if index > 0 {
                previousCoordinator = self.navigationStack[index-1].coordinator
            } else {
                previousCoordinator = coordinatorToRemove
            }
            let context = NavigationContext(
                navigator: self,
                from: coordinatorToRemove,
                to: previousCoordinator,
                by: navStackItem.presentMethod,
                params: params)

            coordinatorToRemove.didDismiss(context: context)
            self.navigatorManagedNavigationStack.remove(at: index)
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
            // as we remove view controllers, we always expect the 
            guard vc === self.navigationStack.last!.viewControllersAndPresentMethods.last!.vc else {
                fatalError("Wrong")
            }
            
            self.navigationStack.last!.viewControllersAndPresentMethods.removeLast()
            if self.navigationStack.last!.viewControllersAndPresentMethods.isEmpty {
                let coordinatorToRemove: AnyCoordinator = self.navigationStack.last!.coordinator
                
                let navStackItem: Navigation = self.navigationStack.last!
                let previousCoordinator: AnyCoordinator
                if index > 0 {
                    previousCoordinator = self.navigationStack[index-1].coordinator
                } else {
                    previousCoordinator = coordinatorToRemove
                }
                let context = NavigationContext(
                    navigator: self,
                    from: coordinatorToRemove,
                    to: previousCoordinator,
                    by: navStackItem.presentMethod,
                    params: Set<NavigationParameter>.defaults)
                
                self.navigatorManagedNavigationStack.removeLast()
                coordinatorToRemove.didDismiss(context: context)
            }
        }
    }
    
    internal func viewControllerDidAppear(_ viewController: UIViewController, coordinator: AnyCoordinator, presentMethod: PresentMethod) {
        if let navController = viewController as? UINavigationController, let topVC = navController.topViewController {
            coordinator.navigation.viewControllersAndPresentMethods.append((topVC, presentMethod))
        } else {
            coordinator.navigation.viewControllersAndPresentMethods.append((viewController, presentMethod))
        }
    }

    internal func viewControllerDidDisappear(_ viewController: UIViewController, coordinator: AnyCoordinator) {
        if self.shouldIgnoreNavControllerPopRequests {
            return
        }

        guard coordinator === self.currentCoordinator else {
            fatalError("Misalignment of view controllers and coordinators on the nav stack.")
        }
        coordinator.navigation.viewControllersAndPresentMethods.removeLast()
        if coordinator.navigation.viewControllersAndPresentMethods.isEmpty {
            self.goBack()
        }
    }
    
    // MARK: Precondition evaluation
    
    /**
     Evaluate the preconditions on a given coordinator.
     */
    private func evaluatePreconditions(on coordinator: NavigationPreconditionRequiring, context: NavigationContext,
    completion: @escaping (Error?) -> Void) -> [PreconditionRecoveryMethod] {
        
        let dispatchGroup = DispatchGroup()
        var preconditionErrors: [Error] = []
        var recoveryMethods: Set<PreconditionRecoveryMethod> = []
        
        // instantiate an instance of each precondition and evaluate them
        for precondition: NavigationPrecondition in type(of: coordinator).preconditions {
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
                completion(preconditionErrors.first)
            } else {
                completion(nil)
            }
        }
        
        return Array(recoveryMethods)
    }
}
