
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
    public let parameters: Set<NavigationParameter>
    /// The navigator handling the navigation.
    public let navigator: Navigator
    
    internal init(navigator: Navigator, from: AnyCoordinator, to: AnyCoordinator, by: PresentMethod, params: Set<NavigationParameter>) {
        self.navigator = navigator
        self.fromCoordinator = from
        self.toCoordinator = to
        self.requestedPresentMethod = by
        self.parameters = params
    }
}

/**
 An enum containing additional parameters regarding view controller presentation and other elements of navigation that
 a coordinator should follow. Some of these parameters are used by the navigator for performing work on its navigation
 stack, while others are passed on to the presented coordinator for it to use when presenting its first view controller.
 */
public enum NavigationParameter: Equatable, Hashable {
    /// The modal transition style that should be used for the navigation.
    case modalTransitionStyle(UIModalTransitionStyle)
    /// The modal presentation style that should be used for the navigation.
    case modalPresentationStyle(UIModalPresentationStyle)
    /// Whether the navigation should be animated.
    case shouldAnimateTransition(Bool)
    /// Has the navigator clear the coordinators on its stack back to the last coordinator of the given type after the
    /// coordinator being presented has finished presenting.
    case clearBackTo(AnyCoordinator.Type)
    
    case addPreconditions([NavigationPrecondition])
    /// A custom parameter containing a flag or value specific to your application logic.
    case custom(key: String, value: Any)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .modalTransitionStyle(_): hasher.combine(0)
        case .modalPresentationStyle(_): hasher.combine(1)
        case .shouldAnimateTransition(_): hasher.combine(2)
        case .clearBackTo(_): hasher.combine(3)
        case .addPreconditions(_): hasher.combine(4)
        case .custom(let key, _): hasher.combine(key.hashValue)
        }
    }
    
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
    public static let defaults: Set<NavigationParameter> = [
        .modalTransitionStyle(.coverVertical),
        .modalPresentationStyle(.overFullScreen),
        .shouldAnimateTransition(true)
    ]
    
    /// The default set of parameters with `animateTransition` set to `false`.
    public static var noAnimation: Set<NavigationParameter> {
        return NavigationParameter.defaults.replacingValues(in: [.shouldAnimateTransition(false)])
    }
}

public extension Set where Element == NavigationParameter {
    /// A convenience parameter set of all the UIKit default parameters.
    static var defaults: Set<NavigationParameter> {
        return NavigationParameter.defaults
    }
    
    /// The default set of parameters with `animateTransition` set to `false`.
    static var noAnimation: Set<NavigationParameter> {
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
    var customParameters: Set<NavigationParameter> {
        return self.filter({
            switch $0 {
            case .custom: return true
            default: return false
            }
        })
    }
    
    func replacingValues(in replacement: Set<NavigationParameter>) -> Set<NavigationParameter> {
        var replaced: Set<NavigationParameter> = self
        for replacementValue in replacement {
            replaced.update(with: replacementValue)
        }
        return replaced
    }
}
