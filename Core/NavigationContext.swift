
import UIKit

/**
 An object containing information about a navigation operation, most notably the involved coordinators and the requested
 presentation method.
 */
public struct NavigationContext {
    /// The coordinator being navigated away from. Will be `nil` if this is the first coordinator navigation.
    public let fromCoordinator: BaseCoordinator?
    /// The coordinator being navigated to.
    public let toCoordinator: BaseCoordinator
    /// The presentation method requested to be used to present the to coordinator's first view controller. Will be
    /// `nil` if the navigation is a dismissal.
    public let requestedPresentMethod: PresentMethod?
    /// The dissmissal method requested to be used to dismiss the coordinator's top view controller Will be `nil` if
    /// the navigation is a presentation.
    public let requestedDismissMethod: DismissMethod?
    /// Other parameters for the navigation, such as the requested modal presentation style.
    public let parameters: NavigationParameters
    /// The navigator handling the navigation.
    public let navigator: Navigator
    
    internal init(navigator: Navigator, from: BaseCoordinator?, to: BaseCoordinator, present: PresentMethod?,
    dismiss: DismissMethod?, params: NavigationParameters) {
        self.navigator = navigator
        self.fromCoordinator = from
        self.toCoordinator = to
        self.requestedPresentMethod = present
        self.requestedDismissMethod = dismiss
        self.parameters = params
    }
}

/**
 An enum describing a type of presentation between view controllers, such as a navigation controller push or modal
 present.
 */
public enum PresentMethod: Equatable {
    /// The view controller should be pushed with a navigation controller.
    case pushing
    /// The view controller should be modally presented.
    case modallyPresenting
    /// The view controller should be set as the root view controller of the associated window. This should only be
    /// used for the first view controller.
    case addingAsRoot(window: UIWindow)
    /// The view controller should be presented by switching to its tab on the tab bar controller. The view controller
    /// must be one of the root view controllers of the navigator's assigned `UITabBarController` to use this method.
    case switchingToTab
    
    internal var inverseDismissMethod: DismissMethod {
        switch self {
        case .modallyPresenting:
            return .modallyDismissing
        case .pushing:
            return .popping
        case .addingAsRoot, .switchingToTab:
            return .none
        }
    }
    
    public static func ==(lhs: PresentMethod, rhs: PresentMethod) -> Bool {
        switch (lhs, rhs) {
        case (.pushing, .pushing):
            return true
        case (.modallyPresenting, .modallyPresenting):
            return true
        case (.addingAsRoot, .addingAsRoot):
            return true
        case (.switchingToTab, .switchingToTab):
            return true
        default:
            return false
        }
    }
}

/**
 An enum describing a type of dismissal between view controllers, such as a navigation controller pop or modal
 dismiss.
 */
public enum DismissMethod {
    /// The view controller should be popped from its navigation controller.
    case popping
    /// The view controller should be modally dismissed.
    case modallyDismissing
    /// No dismiss action can occur. This is the dismiss method given for the inverse of a present method with no clear
    /// inverse dismiss method.
    case none
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
