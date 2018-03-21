/*
import Foundation

public enum RoutingError: Error {
    case failedToCreateSetupModel
    case unrecognizedPathComponent(String)
    case unableToPresentCoordinator
}

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
public class RoutingNavigator: Navigator {
    var currentRoute: URL? {
        return nil
    }
    
//    var defaultNavigationInfoProvider: RoutingInfoProvider?
    var routingUrlParser: RoutingURLParser = DefaultRoutingURLParser()
    
    var routingDelegates: [Routing] = []
    
    fileprivate typealias NavigationHandler
        = (_ previousCoordinator: BaseCoordinator?, _ queryItems: [String: String], Routing) throws -> Void
    
    private var navHandlersForPathComponents: [String: NavigationHandler] = [:]
    
    @discardableResult
    public override func start<T: RoutableCoordinator>(onWindow window: UIWindow, firstCoordinator: T.Type, with model: T.SetupModel) -> T {
        return super.start(onWindow: window, firstCoordinator: firstCoordinator, with: model)
    }
    
    // MARK: Route handling methods
    
    /**
     Register the given routable coordinator to allow it to be routed via URLs.
     
     In order for a coordinator to be navigable via URLs, its path component must be registered with the routing
     navigator. This method should be called just after the navigator is created, and should be called once for each
     coordinator in the application.
     - parameter coordinatorType: The routable coordinator to register.
     */
//    func register<T: RoutableCoordinator>(_ coordinatorType: T.Type) {
//        let handler: NavigationHandler = { [weak self] (previousCoordinator, queryItems, routeInfoProvider) in
//            do {
//                let (model, presentMethod, parameters)
//                    = try routeInfoProvider.routingInfo(for: coordinatorType, presentedFrom: previousCoordinator, queryItems: queryItems)
//                self?.go(to: coordinatorType, by: presentMethod, with: model, parameters: parameters)
//            } catch {
//                throw error
//            }
//        }
//        self.navHandlersForPathComponents[coordinatorType.pathSegment] = handler
//    }
    
    /**
     Register the given routable coordinator to allow it to be routed via URLs.
     
     In order for a coordinator to be navigable via URLs, its path component must be registered with the routing
     navigator. This method should be called just after the navigator is created, and should be called once for each
     coordinator in the application.
     - parameter flowCoordinatorType: The routable flow coordinator to register.
     */
//    func register<T: RoutableFlowCoordinator>(_ flowCoordinatorType: T.Type) {
//        let handler: NavigationHandler = { [weak self] (previousCoordinator, queryItems, routeInfoProvider) in
//            do {
//                let (model, presentMethod, parameters, completion)
//                    = try routeInfoProvider.routingInfo(for: flowCoordinatorType, presentedFrom: previousCoordinator, queryItems: queryItems)
//                self?.go(to: flowCoordinatorType, by: presentMethod, with: model, parameters: parameters, flowCompletion: completion)
//            } catch {
//                throw error
//            }
//        }
//        self.navHandlersForPathComponents[flowCoordinatorType.pathSegment] = handler
//    }
    
    /*
     TODO:
     - (option) cache the previous route in case this route is meant to interrupt it (like a deep link flow)
     - (option) overwrite the existing route and replace it with this one
     - (option) block that gets called for each coordinator created
     */
    func handle(route: URL) throws {
        guard self.routingUrlParser.parseableUrls.contains(route) || self.routingUrlParser.parseableUrls.isEmpty else {
            return
        }
        
//        var navHandlers: [NavigationHandler] = []
        
        let pathSegments = self.routingUrlParser.pathSegments(from: route)
        for (pathSegment, parameters) in pathSegments {
            if let prevCoordinator = self.currentCoordinator as? Routing,
            prevCoordinator.routableCoordinators.contains(where: { $0.pathSegment == pathSegment }) {
                prevCoordinator.route(toCoordinatorFor: pathSegment, navigator: self, parameters: parameters)
            }
        }
        
//        for pathComponent in pathComponents {
//            if let navHandler: NavigationHandler = self.navHandlersForPathComponents[pathComponent] {
//                navHandlers.append(navHandler)
//            } else {
//                throw RoutingError.unrecognizedPathComponent(pathComponent)
//            }
//        }
        
//        for navHandler in navHandlers {
//
//        }
    }
    
    // MARK: Coordinator navigation methods
    
    /**
     Navigate to the specified coordinator with the given setup model.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    @discardableResult
    public override func go<T: RoutableCoordinator>(to coordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: NavigationParameters = NavigationParameters()) -> T {
        return super.go(to: coordinator, by: navMethod, with: model, parameters: parameters)
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
    public override func checkThenGo<T: RoutableCoordinator & NavigationPreconditionRequiring>(to coordinator: T.Type, by navMethod: PresentMethod,
    with model: T.SetupModel, parameters: NavigationParameters = NavigationParameters(), preconditionCompletion: ((Error?, T?) -> Void)?) {
        super.checkThenGo(to: coordinator, by: navMethod, with: model, parameters: parameters, preconditionCompletion: preconditionCompletion)
    }
    
    // MARK: FlowCoordinator navigation methods
    
    /**
     Navigate to the specified flow coordinator with the given setup model.
     - parameter coordinator: The type of coordinator to navigate to.
     - parameter navMethod: The presentation method to use (e.g. push or modal present).
     - parameter model: A model of the given coordinator's setup model type.
     - parameter parameters: Additional navigation parameters. Optional.
     - parameter flowCompletion: The completion block the flow coordinator will call when its flow has completed.
     */
    @discardableResult
    public override func go<T: RoutableFlowCoordinator>(to flowCoordinator: T.Type, by navMethod: PresentMethod, with model: T.SetupModel,
    parameters: NavigationParameters = NavigationParameters(), flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) -> T {
        return super.go(to: flowCoordinator, by: navMethod, with: model, parameters: parameters, flowCompletion: flowCompletion)
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
    public override func checkThenGo<T: RoutableFlowCoordinator & NavigationPreconditionRequiring>(to flowCoordinatorType: T.Type, by navMethod: PresentMethod,
    with model: T.SetupModel, parameters: NavigationParameters = NavigationParameters(), preconditionCompletion: ((Error?, T?) -> Void)?,
    flowCompletion: @escaping (Error?, T.FlowCompletionModel?) -> Void) {
        super.checkThenGo(to: flowCoordinatorType, by: navMethod, with: model, preconditionCompletion: preconditionCompletion, flowCompletion: flowCompletion)
    }
    
    // MARK: Backwards navigation methods
    
    /**
     Navigate back to the specified coordinator.
     - parameter coordinator: The coordinator to navigate back to.
     - parameter parameters: Additional navigation parameters. Optional.
     */
    public override func goBack(to coordinator: BaseCoordinator, parameters: NavigationParameters = NavigationParameters()) {
        super.goBack(to: coordinator, parameters: parameters)
    }

}
*/
