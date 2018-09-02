import UIKit

/**
 An object containing closures that are called to perform the work of presenting and dismissing a view controller in a
 certain way. An instance of this should describe a view controller presentation method - for example, default
 `PresentMethod` instances provided by Corduroy include `pushing`, `modallyPresenting`, and `switchingToTab`.
 
 Present methods are basically wrappers around two related handler closures that they are created with. The first is the
 `presentHandler` where, given a `PresentContext` object containing all the info about the presentation (e.g. the view
 controller to present, the current view controller, the parameters given in the navigation, etc.), it performs the work
 of presenting the view controller. This handler is called in the process of navigating to a new coordinator when its
 associated `PresentMethod` is given to the navigator. The second closure is the `dismissHandler`, where it is passed in
 a similar `DimissContext` object containing info about the dismissal that it uses to perform the work of dismissing the
 view controller in the inverse. The code that dimisses the view controller must reverse the code that presented the
 view controller; for example, the default `pushing` `PresentMethod` pushes the given view controller on a navigation
 controller in its `presentHandler`, then pops the view controller from the navigation controller in its dismiss method.
 
 `PresentMethod` instances are the verbs given to the navigator when going to a new coordinator. Custom present methods
 can be created by adding an extension on `PresentMethod` with a new static `PresentMethod` property. It is recommended
 that your custom present methods be named using a verb in the gerund form (e.g. `pushing`, `switching`, etc). This
 would look something like this:
 ```
 extension PresentMethod {
    static let usingMyCoolAnimation = PresentMethod(
        presentHandler: { (context: PresentContext) {
            // work to present the view controller
        },
        dismissHandler: { (context: DismissContext) {
            // work to dismiss the view controller in an inverse way
        }
    )
 }
 ```
 */
public struct PresentMethod {
    /// An object that is passed into a `PresentMethod`'s `presentHandler` that contains the information that the
    /// handler uses to present a view controller.
    public struct PresentContext {
        /// The navigator performing the navigation.
        public let navigator: Navigator
        /// The view controller to present the new view controller from. Will be `nil` if the view controller being
        /// presented is the first view controller.
        public let currentViewController: UIViewController?
        /// The view controller that the present handler should present.
        public let viewControllerToPresent: UIViewController
        /// The parameters given to the navigator to perform the navigation with.
        public let parameters: NavigationParameters
    }
    
    /// An object that is passed into a `PresentMethod`'s `dismissHandler` that contains the information that the
    /// handler uses to dismiss a view controller.
    public struct DismissContext {
        /// The navigator performing the navigation.
        public let navigator: Navigator
        /// The view controller 'below' the current view controller that should be dismissed to.
        public let previousViewController: UIViewController
        /// The view controller to dismiss.
        public let viewControllerToDismiss: UIViewController
        /// The parameters given to the navigator to perform the navigation with.
        public let parameters: NavigationParameters
    }
    
    /**
     Whether the view controller being presented should be embedded in a `UINavigationController` if it conforms to
     `NavigationControllerEmbedded`. If the present method embeds the view controller in a navigation controller
     itself or if it is expected to already be in one (such as for the `pushing` present method), this should be set
     to false to ensure Corduroy doesn't try to embed a view controller already in a navigation controller. Otherwise,
     it should be left as true.
     */
    public let shouldAutomaticallyEmbedNavigationControllers: Bool
    /// The closure called when this present method is used to navigate to a new coordinator that presents the given
    /// view controller.
    public let presentHandler: (_ context: PresentContext) -> Void
    /// The closure called when a view controller should be dismissed that used this present method to be presented.
    public let dismissHandler: (_ context: DismissContext) -> Void
    /// The name for this present method. This should be a human-readable string that can be used to identify the
    /// present method, especially for debugging.
    public let name: String
    
    public init(name: String,
                shouldAutomaticallyEmbedNavigationControllers: Bool = true,
                presentHandler: @escaping (_ context: PresentContext) -> Void,
                dismissHandler: @escaping (_ context: DismissContext) -> Void)
    {
        self.name = name
        self.shouldAutomaticallyEmbedNavigationControllers = shouldAutomaticallyEmbedNavigationControllers
        self.presentHandler = presentHandler
        self.dismissHandler = dismissHandler
    }
}

extension PresentMethod: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "PresentMethod.\(self.name)"
    }
}

public extension PresentMethod {
    /**
     A present method that pushes a view controller in a navigation controller.
     
     Use of this method assumes that the current view controller that the new view controller is being pushed from is
     already contained in a navigation controller.
     */
    public static let pushing: PresentMethod = PresentMethod(
        name: "pushing",
        shouldAutomaticallyEmbedNavigationControllers: false,
        presentHandler: { (context: PresentContext) in
            if context.currentViewController?.navigationController == nil {
                print("""
                    WARNING: Unable to push \(String(describing: context.viewControllerToPresent)); the previous view
                    controller was not in a navigation controller.
                """)
            }
            let animate = context.parameters.animateTransition
            let vc = context.viewControllerToPresent
            context.currentViewController?.navigationController?.pushViewController(vc, animated: animate)
        },
        dismissHandler: { (context: DismissContext) in
            let animate = context.parameters.animateTransition
            let navController = context.viewControllerToDismiss.navigationController
            navController?.popViewController(animated: animate)
        })
    
    /**
     A present method that modally presents a view controller. This presents the view controller using the presentation
     and transition styles given in the navigation's parameters.
     */
    public static let modallyPresenting: PresentMethod = PresentMethod(
        name: "modallyPresenting",
        presentHandler: { (context) in
            let vc = context.viewControllerToPresent
            let animate = context.parameters.animateTransition
            vc.modalPresentationStyle = context.parameters.modalPresentationStyle
            vc.modalTransitionStyle = context.parameters.modalTransitionStyle
            context.currentViewController?.present(vc, animated: animate, completion: nil)
        }, dismissHandler: { (context) in
            let animate = context.parameters.animateTransition
            context.previousViewController.dismiss(animated: animate, completion: nil)
        })
}

internal extension PresentMethod {
    static let addingAsRoot: PresentMethod = PresentMethod(
        name: "addingAsRoot",
        presentHandler: { (context) in
            context.navigator.window.rootViewController = context.viewControllerToPresent
        }, dismissHandler: { _ in })
}
