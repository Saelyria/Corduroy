
import Foundation

/**
 A protocol describing a coordinator that can be routed to via URLs.
 */
public protocol RoutableCoordinator: Coordinator, BaseRoutableCoordinator where SetupModel: RouteParameterConvertible { }



/**
 A protocol describing a flow coordinator that can be routed to via URLs.
 */
public protocol RoutableFlowCoordinator: FlowCoordinator, BaseRoutableCoordinator where SetupModel: RouteParameterConvertible { }



/**
 A protocol describing a coordinator or flow coordinator that can be routed to via URLs.
 
 This protocol should not be conformed to on its own; instead, conform to one of either `RoutableCoordinator` or
 `RoutableFlowCoordinator`.
 */
public protocol BaseRoutableCoordinator: BaseCoordinator {
    static var pathComponent: String { get }
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
