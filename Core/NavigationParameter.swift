
import UIKit

/**
 An enum describing a type of navigation between view controllers, such as a navigation controller push/pop or modal
 present/dismiss. Can be either `PresentMethod` or `DismissMethod`.
 */
public protocol NavigationMethod { }

/**
 An enum describing a type of presentation between view controllers, such as a navigation controller push or modal
 present.
 */
public enum PresentMethod: NavigationMethod {
    case pushing
    case modallyPresenting
    case addingAsChild
    
    public var inverseDismissMethod: DismissMethod {
        switch self {
        case .addingAsChild:
            return .removingFromParent
        case .modallyPresenting:
            return .modallyDismissing
        case .pushing:
            return .popping
        }
    }
}

/**
 An enum describing a type of dismissal between view controllers, such as a navigation controller pop or modal
 dismiss.
 */
public enum DismissMethod: NavigationMethod {
    case popping
    case modallyDismissing
    case removingFromParent
}



/**
 An enum describing an additional parameter regarding view controller navigation that a coordinator should follow.
 */
public enum NavigationParameterKey: Hashable {
    case modalTransitionStyle
    case modalPresentationStyle
    case animateTransition
    
    public var hashValue: Int {
        switch self {
        case .modalTransitionStyle: return 1
        case .modalPresentationStyle: return 2
        case .animateTransition: return 3
        }
    }
    
    internal static func defaultParameters(withOverrides overrides: [NavigationParameterKey: Any]) -> [NavigationParameterKey: Any] {
        var defaults: [NavigationParameterKey: Any] = [
            .modalTransitionStyle: UIModalTransitionStyle.coverVertical,
            .modalPresentationStyle: UIModalPresentationStyle.none,
            .animateTransition: true
        ]
        
        if let overrideModalTransitionStyle = overrides[.modalTransitionStyle] {
            guard overrideModalTransitionStyle is UIModalTransitionStyle else {
                fatalError("Found an object that wasn't a UIModalTransitionStyle in the navigation parameters dictionary under the .modalTransitionStyle key")
            }
            defaults[.modalTransitionStyle] = overrideModalTransitionStyle
        }
        if let overrideModalPresentatinStyle = overrides[.modalPresentationStyle] {
            guard overrideModalPresentatinStyle is UIModalPresentationStyle else {
                fatalError("Found an object that wasn't a UIModalPresentationStyle in the navigation parameters dictionary under the .modalPresentationStyle key")
            }
            defaults[.modalPresentationStyle] = overrideModalPresentatinStyle
        }
        if let overrideAnimateTransition = overrides[.animateTransition] {
            guard overrideAnimateTransition is Bool else {
                fatalError("Found an object that wasn't a Bool in the navigation parameters dictionary under the .animateTransition key")
            }
            defaults[.animateTransition] = overrideAnimateTransition
        }
        return defaults
    }
}

public func == (lhs: NavigationParameterKey, rhs: NavigationParameterKey) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
