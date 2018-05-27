import UIKit

/**
 A protocol that a view controller that expects to be embedded in a navigation controller should conform to.
 
 When creating and presenting view controllers using Corduroy, you shouldn't handle the creation of
 `UINavigationController`s - instead, have your view controllers that you expect to be in a navigation controller
 conform to this protocol. When a view controller conforming to this protocol is presented with a coordinator, the
 coordinator will ensure the view controller is embedded in a `UINavigationController`. If the view controller is being
 presented via a push, the coordinator will use the previous view controller's navigation controller, as expected. If
 the view controller is being presented any other way (modal present, added as the root view controller, etc), the
 coordinator will handle the creation of the navigation controller and the setting of the view controller as its root.
 
 A `NavigationControllerEmbedded` view controller can also specify a custom `UINavigationController` subclass that it
 wants its navigation controller to be. The coordinator will then ensure that the view controller is only pushed on a
 navigation controller of this type (and will crash a debug build to catch programmer error) and will create a
 navigation controller of the view controller's type when embedding it in a new one.
 */
public protocol NavigationControllerEmbedded where Self: UIViewController {
//    /// The type of navigation controller the view controller expects to be embedded in. Defaults to a vanilla
//    /// `UINavigationController`.
//    associatedtype NavigationControllerType: UINavigationController = UINavigationController

    /// A method that the coordinator calls to create the view controller's navigation controller if it needs to create
    /// one. A default implementation is provided if the navigation controller type is just `UINavigationController`.
    func createNavigationController() -> UINavigationController
}

public extension NavigationControllerEmbedded {
    func createNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}

//extension NavigationControllerEmbedded where Self.NavigationControllerType == CoordinatedNavigationController {
//    static func createNavigationController(rootViewController: Self) -> NavigationControllerType {
//        return CoordinatedNavigationController(rootViewController: rootViewController, navigator: <#T##Navigator#>)
//    }
//}
