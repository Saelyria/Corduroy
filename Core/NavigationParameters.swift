
import UIKit

/**
 An object containing information about a navigation operation, most notably the involved coordinators and the
 current view controller that the 'to' coordinator should start from.
 */
public struct NavigationContext {
    /// The current view controller managed by the from coordinator that the to coordinator should navigate from.
    /// Will be `nil` if this is the first coordinator navigation.
    public let currentViewController: UIViewController?
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
    
    internal init(navigator: Navigator, viewController: UIViewController?, from: BaseCoordinator?,
                  to: BaseCoordinator, present: PresentMethod?, dismiss: DismissMethod?, params: NavigationParameters) {
        self.navigator = navigator
        self.currentViewController = viewController
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
    case pushing
    case modallyPresenting
    case addingAsChild
    case addingAsRoot(window: UIWindow)
    
    public var inverseDismissMethod: DismissMethod {
        switch self {
        case .addingAsChild:
            return .removingFromParent
        case .modallyPresenting:
            return .modallyDismissing
        case .pushing:
            return .popping
        case .addingAsRoot:
            fatalError("No inverse dismiss method to adding as the root view controller of a window.")
        }
    }
    
    public static func ==(lhs: PresentMethod, rhs: PresentMethod) -> Bool {
        switch (lhs, rhs) {
        case (.pushing, .pushing):
            return true
        case (.modallyPresenting, .modallyPresenting):
            return true
        case (.addingAsChild, .addingAsChild):
            return true
        case (.addingAsRoot, .addingAsRoot):
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
    case popping
    case modallyDismissing
    case removingFromParent
}



/**
 An object containing additional parameters regarding view controller navigation that a coordinator should follow.
 
 Note that its initializer contains the default values used by UIKit - you only need to provide an argument to the
 initializer for values different from the default.
 */
public struct NavigationParameters: Equatable {
    let modalTransitionStyle: UIModalTransitionStyle
    let modalPresentationStyle: UIModalPresentationStyle
    let animateTransition: Bool
    
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
