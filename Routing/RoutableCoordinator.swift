
import Foundation

public protocol Routable: BaseCoordinator {
    static var pathComponent: String { get }
}

/**
 A protocol describing a coordinator that can be routed to via URLs.
 */
public protocol RoutableCoordinator: Coordinator, BaseRoutableCoordinator { }



/**
 A protocol describing a flow coordinator that can be routed to via URLs.
 */
public protocol RoutableFlowCoordinator: FlowCoordinator, BaseRoutableCoordinator { }



/**
 A protocol describing a coordinator or flow coordinator that can be routed to via URLs.
 
 This protocol should not be conformed to on its own; instead, conform to one of either `RoutableCoordinator` or
 `RoutableFlowCoordinator`.
 */
public protocol BaseRoutableCoordinator: BaseCoordinator {
    static var pathComponent: String { get }
}

/**
 A protocol describing an object that can provide the data required to present a coordinator.
 
 A `RouteParameterProviding` object has to implement two methods - one for `Coordinator` objects and another for
 `FlowCoordinator` objects - where they must provide the setup model, present method, and navigation parameters for the
 navigation to the given coordinator. In the case of a flow coordinator, it must also provide the 'flow completion'
 closure.
 */
public protocol RouteParameterProviding {
    func routeParameters<T: RoutableCoordinator>(`for` coordinator: T.Type, routeParameterValue: String)
        throws -> (T.SetupModel, PresentMethod, NavigationParameters)
    
    func routeParameters<T: RoutableFlowCoordinator>(`for` flowCoordinator: T.Type, routeParameterValue: String)
        throws -> (T.SetupModel, PresentMethod, NavigationParameters, (Error?, T.FlowCompletionModel?) -> Void)
}



/**
 A protocol describing a model object that can be created from the query items or parameters of a URL.
 */
public protocol RouteParameterConvertible {
    init?(routeParameterValue: String)
}



// MARK: RouteParameterConvertible conformance for basic types

extension Nothing: RouteParameterConvertible {
    public init?(routeParameterValue: String) {
        self.init(nilLiteral: ())
    }
}

extension Int: RouteParameterConvertible {
    public init?(routeParameterValue: String) {
        self.init(routeParameterValue)
    }
}

extension Float: RouteParameterConvertible {
    public init?(routeParameterValue: String) {
        self.init(routeParameterValue)
    }
}

extension Double: RouteParameterConvertible {
    public init?(routeParameterValue: String) {
        self.init(routeParameterValue)
    }
}

extension String: RouteParameterConvertible {
    public init?(routeParameterValue: String) {
        self.init(stringLiteral: routeParameterValue)
    }
}
