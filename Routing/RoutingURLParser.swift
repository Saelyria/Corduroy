/*
import Foundation

/**
 A protocol describing an object that parses a URL into individual path segments and parameters for a routing navigator.
 
 The primary job of a routing URL parser is to, from a given URL (most likely from a universal link), return the
 individual path segments and their respective parameters (from either the URL's path parameters or its query items).
 For example, a URL parser would take this URL:
 ```
'.../home/profiles/profile?name=john'
 ```
 then would likely return something like the following array:
 ```
[
    (pathSegment: "home", parameters: [:]),
    (pathSegment: "profiles", parameters: [:]),
    (pathSegment: "profile", parameters: ["name":"john"])
]
 ```
 This object can also be used to better translate universal link URLs into routing URLs, especially where intermediary
 path segments are implied in the universal link URL. For example, a parser could be given '.../profile?name=john'
 as a universal link to the app and wish to extend it to '.../home/profiles/profile?name=john' so that the coordinator
 stack created by the router is more complete. A custom URL parser is also used for filtering or mapping the given
 query items to the appropriate path segments.
 
 Its only method is `pathSegmentsAndParameters(from:)`, where it is expected to,
 with the given URL, return an array of the path segments (each corresponding to a coordinator) and the parameters for
 each segment.
 */
protocol RoutingURLParser {
    typealias PathSegment = (pathSegment: String, parameters: [String: String])
    
    var parseableUrls: [URL] { get }
    
    func pathSegments(from url: URL) -> [PathSegment]
}



/**
 A default routing URL parser that returns all the path segments in the given URL and gives all query items from to URL
 to each path segment as its 'route parameters'.
 */
class DefaultRoutingURLParser: RoutingURLParser {
    let parseableUrls: [URL] = []
    
    func pathSegments(from url: URL) -> [RoutingURLParser.PathSegment] {
        let segments = url.pathComponents.filter({ $0 != "/" })
        let urlComponents = URLComponents(string: url.absoluteString)!
        var parameters: [String: String] = [:]
        urlComponents.queryItems?.forEach({ (item) in
            parameters[item.name] = item.value ?? ""
        })

        var pathSegmentsAndParameters: [RoutingURLParser.PathSegment] = []
        for segment in segments {
            pathSegmentsAndParameters.append((pathSegment: segment, parameters: parameters))
        }
        return pathSegmentsAndParameters
    }
}
*/
