
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
 An object containing additional parameters regarding view controller navigation that a coordinator should follow.
 
 Note that its initializer contains the default values used by UIKit - you only need to provide an argument to the
 initializer for values different from the default.
 */
public struct NavigationParameters {
    let modalTransitionStyle: UIModalTransitionStyle
    let modalPresentationStyle: UIModalPresentationStyle
    let animateTransition: Bool
    
    public init(modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
         modalPresentationStyle: UIModalPresentationStyle = .none,
         animateTransition: Bool = true)
    {
        self.modalTransitionStyle = modalTransitionStyle
        self.modalPresentationStyle = modalPresentationStyle
        self.animateTransition = animateTransition
    }
}
