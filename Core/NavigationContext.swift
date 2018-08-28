
import UIKit

/**
 An object containing information about a navigation operation, most notably the involved coordinators and the requested
 presentation method.
 */
public struct NavigationContext {
    /// The coordinator being navigated away from.
    public let fromCoordinator: BaseCoordinator
    /// The coordinator being navigated to.
    public let toCoordinator: BaseCoordinator
    /// The presentation method requested to be used to present the to coordinator's first view controller. Will be
    /// `nil` if the navigation is a dismissal.
    public let requestedPresentMethod: PresentMethod
    /// Other parameters for the navigation, such as the requested modal presentation style.
    public let parameters: NavigationParameters
    /// The navigator handling the navigation.
    public let navigator: Navigator
    
    internal init(navigator: Navigator, from: BaseCoordinator, to: BaseCoordinator, by: PresentMethod, params: NavigationParameters) {
        self.navigator = navigator
        self.fromCoordinator = from
        self.toCoordinator = to
        self.requestedPresentMethod = by
        self.parameters = params
    }
}

/**
 An object containing additional parameters regarding view controller navigation that a coordinator should follow.
 
 Note that its initializer contains the default values used by UIKit - you only need to provide an argument to the
 initializer for values different from the default.
 */
public struct NavigationParameters: Equatable {
    /// The modal transition style for the navigation.
    let modalTransitionStyle: UIModalTransitionStyle
    /// The modal presentation style for the navigation.
    let modalPresentationStyle: UIModalPresentationStyle
    /// Whether the navigation should be animated.
    let animateTransition: Bool
    
    /// A convenience parameter set of all the UIKit default parameters.
    public static let `default`: NavigationParameters = NavigationParameters()
    /// The default set of parameters with `animateTransition` set to `false`.
    public static let noAnimation: NavigationParameters = NavigationParameters(animateTransition: false)
    
    public init(modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
                modalPresentationStyle: UIModalPresentationStyle = .overFullScreen,
                animateTransition: Bool = true)
    {
        self.modalTransitionStyle = modalTransitionStyle
        self.modalPresentationStyle = modalPresentationStyle
        self.animateTransition = animateTransition
    }
    
    public static func == (lhs: NavigationParameters, rhs: NavigationParameters) -> Bool {
        return lhs.modalTransitionStyle == rhs.modalTransitionStyle &&
            lhs.modalPresentationStyle == rhs.modalPresentationStyle &&
            lhs.animateTransition == rhs.animateTransition
    }
}
