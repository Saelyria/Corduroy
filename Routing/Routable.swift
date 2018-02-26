
import Foundation

public typealias RoutableCoordinator = Coordinator & Routable
public typealias RoutableFlowCoordinator = FlowCoordinator & Routable

/**
 A protocol describing a coordinator or flow coordinator that can be routed to via URLs.
 */
public protocol Routable: BaseCoordinator {
    static var pathSegment: String { get }
}



public protocol RouteParameterInitable {
    init?(routeParameters: [String: String]?)
}


public struct Route {
    static let any: Route = Route(from: nil, to: nil)
    
    let from: Routable.Type?
    let to: Routable.Type?
}


/**
 A protocol describing an object that can present other coordinators when asked to by a routing navigator.
 
 The relationship between a `Routing` object and a `RoutingNavigator` is fairly complex. When a routing navigator is
 asked to handle a routing URL, it will use a number of `Routing` objects in order to properly present all coordinators
 involved in the route. Which `Routing` object it uses is a cascading list it will work its way down. These objects act
 as delegates to the navigator and are effectively used to call `go(to:)` back on the navigator with the appropriate
 present method/navigation parameters/setup model when their `route(to:navigator:parameters:)` method is called.
 
 First, the navigator will check if the coordinator that will present the next coordinator conforms to `Routing`. If it
 does and the coordinator to be presented is included in its `routableCoordinators` array, it will delegate the
 presentation to the coordinator. This is the recommended way to handle the presentation of coordinators that have
 dependencies, especially dependencies like 'delegate' objects that must be passed to them from other specific
 coordinators.
 
 If the top coordinator doesn't conform to `Routing` or the coordinator being presented is not in its list of routable
 coordinators, the navigator will fall back to the objects in its `routingDelegates` array, checking for the first
 object in the array that has the given coordinator in its `routableCoordinators` array.
 
 If none of the navigator's routing delegates can handle the coordinator route, it will attempt to handle the
 navigation itself.
 */
public protocol Routing: AnyObject {
    /**
     The list of coordinators that this coordinator can route to.
     
     A routing navigator will only ever ask a coordinator to route to another coordinator if the latter coordinator's
     type is included in this array. An empty array will be taken to mean this coordinator can route to any other
     coordinator.
     */
    var routableCoordinators: [Routable.Type] { get }
    
    /**
     Asks the coordinator to route to the coordinator with the given path segment.
     
     A routing navigator will call this method on a routable coordinator
     - parameter pathSegment: The path segment
     - parameter parameters: The key-value parameters that were included with the path segment for the
     presented coordinator in the URL being handled by the routing navigator.
     */
    func route(to pathSegment: String, navigator: RoutingNavigator, parameters: [String: String]?)
}
