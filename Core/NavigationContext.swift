
import UIKit

/**
 An object containing information about a navigation operation, most notably the involved coordinators and the requested
 presentation method.
 */
public struct NavigationContext {
    /// The coordinator being navigated away from.
    public let fromCoordinator: AnyCoordinator
    /// The coordinator being navigated to.
    public let toCoordinator: AnyCoordinator
    /// The presentation method requested to be used to present the to coordinator's first view controller. Will be
    /// `nil` if the navigation is a dismissal.
    public let requestedPresentMethod: PresentMethod
    /// Other parameters for the navigation, such as the requested modal presentation style.
    public let parameters: [NavigationParameter]
    /// The navigator handling the navigation.
    public let navigator: Navigator
    
    internal init(navigator: Navigator, from: AnyCoordinator, to: AnyCoordinator, by: PresentMethod, params: [NavigationParameter]) {
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
//public struct NavigationParameters: Equatable {
//    /// The modal transition style for the navigation.
//    let modalTransitionStyle: UIModalTransitionStyle
//    /// The modal presentation style for the navigation.
//    let modalPresentationStyle: UIModalPresentationStyle
//    /// Whether the navigation should be animated.
//    let animateTransition: Bool
//
//    /// A convenience parameter set of all the UIKit default parameters.
//    public static let `default`: NavigationParameters = NavigationParameters()
//    /// The default set of parameters with `animateTransition` set to `false`.
//    public static let noAnimation: NavigationParameters = NavigationParameters(animateTransition: false)
//
//    public init(modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
//                modalPresentationStyle: UIModalPresentationStyle = .overFullScreen,
//                animateTransition: Bool = true)
//    {
//        self.modalTransitionStyle = modalTransitionStyle
//        self.modalPresentationStyle = modalPresentationStyle
//        self.animateTransition = animateTransition
//    }
//
//    public static func == (lhs: NavigationParameters, rhs: NavigationParameters) -> Bool {
//        return lhs.modalTransitionStyle == rhs.modalTransitionStyle &&
//            lhs.modalPresentationStyle == rhs.modalPresentationStyle &&
//            lhs.animateTransition == rhs.animateTransition
//    }
//}

public enum NavigationParameter: Equatable {
    /// The modal transition style to use for the navigation.
    case modalTransitionStyle(UIModalTransitionStyle)
    /// The modal presentation style to use for the navigation.
    case modalPresentationStyle(UIModalPresentationStyle)
    /// Whether the navigation should be animated.
    case shouldAnimateTransition(Bool)
    /// A custom parameter containing a flag specific to your application.
    case custom(Any)
    
    public static func == (lhs: NavigationParameter, rhs: NavigationParameter) -> Bool {
        switch (lhs, rhs) {
        case (.modalTransitionStyle(let lhsStyle), .modalTransitionStyle(let rhsStyle)):
            return lhsStyle == rhsStyle
        case (.modalPresentationStyle(let lhsStyle), .modalPresentationStyle(let rhsStyle)):
            return lhsStyle == rhsStyle
        case (.shouldAnimateTransition(let lhsAnimate), .shouldAnimateTransition(let rhsAnimate)):
            return lhsAnimate == rhsAnimate
        default:
            return false
        }
    }
    
    /// A convenience parameter set of all the UIKit default parameters.
    public static let defaults: [NavigationParameter] = [
        .modalTransitionStyle(.coverVertical),
        .modalPresentationStyle(.overFullScreen),
        .shouldAnimateTransition(true)
    ]
    
    /// The default set of parameters with `animateTransition` set to `false`.
    public static let noAnimation: [NavigationParameter] = [
        .modalTransitionStyle(.coverVertical),
        .modalPresentationStyle(.overFullScreen),
        .shouldAnimateTransition(false)
    ]
}

public extension Array where Element == NavigationParameter {
    /// A convenience parameter set of all the UIKit default parameters.
    public static var defaults: [NavigationParameter] {
        return NavigationParameter.defaults
    }
    
    /// The default set of parameters with `animateTransition` set to `false`.
    public static var noAnimation: [NavigationParameter] {
        return NavigationParameter.noAnimation
    }
    
    /// Whether the parameters in the array indicate that the transition should be animated. Defaults to `true` if a
    /// the 'should animate transition' case was not included.
    var shouldAnimateTransition: Bool {
        var shouldAnimate = true
        for parameter in self {
            switch parameter {
            case .shouldAnimateTransition(let animate):
                shouldAnimate = animate
            default: break
            }
        }
        return shouldAnimate
    }
    
    /// The modal transition style indicated by the parameters in the array. Defaults to `.coverVertical` if a
    /// transition style was not included.
    var modalTransitionStyle: UIModalTransitionStyle {
        var modalTransitionStyle: UIModalTransitionStyle = .coverVertical
        for parameter in self {
            switch parameter {
            case .modalTransitionStyle(let style):
                modalTransitionStyle = style
            default: break
            }
        }
        return modalTransitionStyle
    }
    
    /// The modal presentation style indicated by the parameters in the array. Defaults to `.overFullScreen` if a
    /// presentation style was not included.
    var modalPresentationStyle: UIModalPresentationStyle {
        var modalPresentationStyle: UIModalPresentationStyle = .overFullScreen
        for parameter in self {
            switch parameter {
            case .modalPresentationStyle(let style):
                modalPresentationStyle = style
            default: break
            }
        }
        return modalPresentationStyle
    }
    
    /// All of the `custom` parameters included in the array.
    var customParameters: [NavigationParameter] {
        return self.filter({
            switch $0 {
            case .custom: return true
            default: return false
            }
        })
    }
}
