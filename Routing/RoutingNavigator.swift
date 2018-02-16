
import Foundation

/**
 An object that handles navigation between coordinators.
 
 All navigation between coordinators should be handled through a `Navigator` object. The navigator will handle the
 creation of navigation context objects (which hold information like the involved coordinators) and evaluate any
 preconditions that a coordinator may have as a requirement for navigation to it.
 
 `RoutingNavigator`s are special navigators that can handle navigation via URLs. At any point in time, the navigation
 state of an application can be expressed by the navigator's `currentRoute` property, which is a URL representation of
 the navigator's navigation stack where each path component corresponds to a coordinator that was previously navigated
 to. When a coordinator is navigated to via one of the `go(to:)` methods, that coordinator's `pathComponent` is
 automatically added to the navigator's `currentRoute`.
 */
public class RoutingNavigator {
    public enum RoutingError: Error {
        case failedToCreateSetupModel
        case unrecognizedPathComponent(String)
    }
    
    typealias NavigationHandler = (_ routeParameterValue: String, PresentMethod, NavigationParameters) -> Void
    
    var currentRoute: URL? {
        return nil
    }
    
    private let navigator: Navigator = Navigator()
    private var coordinatorTypesForPathComponents: [String: BaseRoutableCoordinator.Type] = [:]
    private var navHandlersForPathComponents: [String: NavigationHandler] = [:]
    
    @discardableResult
    public func start<T: RoutableCoordinator>(onWindow window: UIWindow, firstCoordinator: T.Type) -> T where T.SetupModel == Nothing {
        return self.navigator.start(onWindow: window, firstCoordinator: firstCoordinator, with: nil)
    }
    
    @discardableResult
    public func start<T: RoutableCoordinator>(onWindow window: UIWindow, firstCoordinator: T.Type, with model: T.SetupModel) -> T {
        return self.navigator.start(onWindow: window, firstCoordinator: firstCoordinator, with: model)
    }
    
    // MARK: Route handling methods
    
    /**
     Register the given routable coordinator to allow it to be routed via URLs.
     
     In order for a coordinator to be navigable via URLs, its path component must be registered with the routing
     navigator. This method should be called just after the navigator is created, and should be called once for each
     coordinator in the application.
     - parameter coordinatorTypes: The routable coordinator to register.
     */
    func register<T: RoutableCoordinator>(_ coordinatorType: T.Type) {
        let handler: NavigationHandler = { [weak self] (routeParameterValue: String, presentMethod: PresentMethod, parameters: NavigationParameters) in
            if let model = T.SetupModel(routeParameterValue: routeParameterValue) {
                self?.go(to: coordinatorType, by: presentMethod, with: model, parameters: parameters)
            }
        }
        self.navHandlersForPathComponents[coordinatorType.pathComponent] = handler
    }
    
    /*
     TODO:
     - (option) cache the previous route in case this route is meant to interrupt it (like a deep link flow)
     - (option) overwrite the existing route and replace it with this one
     - (option) block that gets called for each coordinator created
     */
    func handle(route: URL) throws {
        var navHandlers: [NavigationHandler] = []
        
        let components = URLComponents(string: route.absoluteString)!
        let path = components.path
        let pathComponents: [String] = path.split(separator: "/").map({ String($0) })
        for pathComponent in pathComponents {
            if let navHandler: NavigationHandler = self.navHandlersForPathComponents[pathComponent] {
                navHandlers.append(navHandler)
            } else {
                throw RoutingError.unrecognizedPathComponent(pathComponent)
            }
        }
        
        for navHandler in navHandlers {
            
        }
    }
    
    // MARK: Coordinator navigation methods
    
    /**
     Navigate to the specified coordinator.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter parameters: Additional navigation parameters. Optional.
     */
    @discardableResult
    public func go<T: RoutableCoordinator>(to coordinator: T.Type, by navMethod: PresentMethod,
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
    public func go<T: RoutableCoordinator>(to coordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: NavigationParameters = NavigationParameters()) -> T {
        return self.navigator.go(to: coordinator, by: navMethod, with: model, parameters: parameters)
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
    public func evaluatePreconditionsAndGo<T: RoutableCoordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod,
    parameters: NavigationParameters = NavigationParameters(), evaluationCompletion: @escaping (Error?, T?) -> Void) where T.SetupModel == Nothing {
        self.navigator.evaluatePreconditionsAndGo(to: coordinator, by: navMethod, with: nil, evaluationCompletion: evaluationCompletion)
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
    public func evaluatePreconditionsAndGo<T: RoutableCoordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod,
    with model: T.SetupModel, parameters: NavigationParameters = NavigationParameters(), evaluationCompletion: @escaping (Error?, T?) -> Void) {
        self.navigator.evaluatePreconditionsAndGo(to: coordinator, by: navMethod, with: model, parameters: parameters, evaluationCompletion: evaluationCompletion)
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
    public func go<T: RoutableFlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod,
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
    public func go<T: RoutableFlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: NavigationParameters = NavigationParameters(), flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) -> T {
        return self.navigator.go(to: flowCoordinator, by: navMethod, with: model, parameters: parameters, flowCompletion: flowCompletion)
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
    public func evaluatePreconditionsAndGo<T: RoutableFlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod,
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
    public func evaluatePreconditionsAndGo<T: RoutableFlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod,
    with model: T.SetupModel, parameters: NavigationParameters = NavigationParameters(), evaluationCompletion: @escaping (Error?, T?) -> Void,
    flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) {
        self.navigator.evaluatePreconditionsAndGo(to: flowCoordinatorType, by: navMethod, with: model, evaluationCompletion: evaluationCompletion, flowCompletion: flowCompletion)
    }
    
    // MARK: Backwards navigation methods
    
    /**
     Navigate back to the previous coordinator.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack(parameters: NavigationParameters = NavigationParameters()) {
        self.navigator.goBack(parameters: parameters)
    }
    
    /**
     Navigate back to the last coordinator of the specified coordinator type.
     - parameter coordinatorType: The coordinator type to navigate back to.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack<T: BaseCoordinator>(toLast coordinatorType: T.Type, parameters: NavigationParameters = NavigationParameters()) {
        self.navigator.goBack(toLast: coordinatorType, parameters: parameters)
    }
    
    /**
     Navigate back to the specified coordinator.
     - parameter coordinator: The coordinator to navigate back to.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public func goBack(to coordinator: BaseCoordinator, parameters: NavigationParameters = NavigationParameters()) {
        self.navigator.goBack(to: coordinator, parameters: parameters)
    }

}
