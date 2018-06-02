
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

public struct _PresentMethod {
    public struct PresentContext {
        public let navigator: Navigator
        public let currentViewController: UIViewController?
        public let viewControllerToPresent: UIViewController
        public let window: UIWindow
        public let currentCoordinator: BaseCoordinator?
        public let parameters: NavigationParameters
    }
    
    public let handler: (_ context: PresentContext) -> Void
    
    public init(handler: @escaping (_ context: PresentContext) -> Void) {
        self.handler = handler
    }
}

public extension _PresentMethod {
    public static let pushing: _PresentMethod = _PresentMethod { (context) in
        let animate = context.parameters.animateTransition
        let vc = context.viewControllerToPresent
        context.currentViewController?.navigationController?.pushViewController(vc, animated: animate)
    }
    
    public static let modallyPresenting: _PresentMethod = _PresentMethod { (context) in
        let vc = context.viewControllerToPresent
        let animate = context.parameters.animateTransition
        vc.modalPresentationStyle = context.parameters.modalPresentationStyle
        vc.modalTransitionStyle = context.parameters.modalTransitionStyle
        context.currentViewController?.present(vc, animated: animate, completion: nil)
    }
}

internal extension _PresentMethod {
    static let addingAsRoot: _PresentMethod = _PresentMethod { (context) in
        context.window.rootViewController = context.viewControllerToPresent
    }
    
    static let switchingToTab: _PresentMethod = _PresentMethod { (context) in
        
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
    
    internal var inverseDismissMethod: DismissMethod {
        switch self {
        case .modallyPresenting:
            return .modallyDismissing
        case .pushing:
            return .popping
        case .addingAsRoot:
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
