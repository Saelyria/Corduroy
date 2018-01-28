
import UIKit

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
