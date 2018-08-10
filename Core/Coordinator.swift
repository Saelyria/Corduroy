
import UIKit

/**
 A protocol describing an object that manages navigation logic and acts as the primary 'navigation item'.
 
 When using Corduroy, navigation in the application is done to and from 'coordinators' instead of view controllers. A
 coordinator is the interface to a 'page' or 'section' of your app - home, login, product list, product details, etc.
 Coordinators use 'managed' view controllers (view controllers conforming to `CoordinatorManageable`) to manage the
 associated views of those sections. All navigation logic (e.g. 'go to this screen when this button is pressed') should
 be contained in coordinator objects - view controllers should report back to their coordinator whenever an action is
 performed that should navigate somewhere. This allows view controllers to be more reusable and less coupled to specific
 parts of the application.
 
 Dependencies for a coordinator (e.g. the account or product details to display) can be defined via its `SetupModel`
 associated type. Defining a setup model type makes it so that instances of the coordinator can only be navigated to
 when an object of this setup model type is also given. This object is passed in to the `create(with:navigator:)` static
 method of the coordinator. This `SetupModel` associated type defaults to `Void` if no explicit type is set. Note that
 coordinators are instantiated with their class's `create(with:navigator:)` methods, so `init` methods shouldn't be
 implemented. If the setup model type is left as `Void`, a default implementation for `create(with:navigator:)` is
 provided.
 
 Depending on the complexity of the view being created, you can decide to have a dedicated coordinator object that your
 view controller delegates to, or your view controller can implement `Coordinator` itself. View controllers conforming
 to `Coordinator` have a default implementation provided for `presentViewController(_:context:)` and
 `create(with:navigator:)`. View controllers that are created from a storyboard should always implement their static
 `create` method, as this default implementation simply creates them with their `init(nibName:bundle:)` initializer.
 */
public protocol Coordinator: BaseCoordinator, SetupModelRequiring {
    /**
     Called when the coordinator is navigated to. In this method, the coordinator should instantiate its first view
     controller and push/present it from the context's `currentViewController`.
     - parameter context: A context object containing the involved coordinators and other navigation details.
     */
    func presentViewController(context: NavigationContext)
}

public extension Coordinator where Self: UIViewController {
    func presentViewController(context: NavigationContext) {
        self.present(self, context: context)
    }
}



/**
 A protocol describing a coordinator that manages navigation in a user flow.
 
 A flow coordinator is a specialized coordinator that is responsible for a set of view controllers in a user 'flow'. A
 user flow is any series of view controllers that are launched with the intention of completing a specific task or for
 returning a specific value; for example, starting a flow to have the user authenticate or starting a flow to
 upload a picture. Flows have a defined start and end. A flow coordinator can also act as the shared 'state' manager for
 the view controllers involved in the flow - for exmaple, in a registration flow where each view controller manages the
 input of one of many registration values like the user's username, their security question, etc, the coordinator can
 hold them all temporarily until a final model is created. Flow coordinators have the same `SetupModel` associated type
 as regular coordinator for managing dependencies.
 
 Flow coordinators are started by other coordinators and are expected to, once completed, call the completion closure
 passed into their `presentFirstViewController(context:flowCompletion:)` method where they will pass in either an error
 if their flow 'failed' or a result object of their `FlowResult` type. This context type could be, as in the example of
 authentication, a type that contains information about whether the authentication was successful and, if so, the
 credentials for the authentication. If the flow doesn't return a model (such as a login flow), `FlowResult` can be left
 as `Void`, in which case the coordinator starting the flow coordinator can provide a `flowCompletion` block ignoring
 this object.
 */
public protocol FlowCoordinator: BaseCoordinator, SetupModelRequiring {
    /// The type of the model object that this flow coordinator will return in its completion containing data about or
    /// as a result of its flow. Defaults to 'Void' if no explicit type is set.
    associatedtype FlowResult = Void
    
    /**
     Called when the flow coordinator is navigated to. In this method, the coordinator should instantiate its first view
     controller and push/present it from the context's `currentViewController`.
     - parameter context: A context object containing the involved coordinators and other navigation details.
     - parameter flowCompletion: A closure to call after the flow has completed.
     */
    func presentFirstViewController(context: NavigationContext, flowCompletion: @escaping (Error?, FlowResult?) -> Void)
}


/**
 A basic protocol that all coordinator types implement. This is mostly used internally and should not be implemented on
 its own - instead, implement one of either `Coordinator`, `FlowCoordinator`, or `SelfCoordinating`.
 */
public protocol BaseCoordinator: AnyObject {
    /// The navigator managing navigation to this coordinator that it should use to perform navigation to other
    /// coordinators.
    var navigator: Navigator! { get set }
    
    /// Whether this coordinator can be navigated back to (i.e. if it should be skipped over when its navigator's
    /// `goBack(to:)` method is called). This can be useful, for example, for precondition recovering flow coordinators
    /// or login view controllers after a user has logged in. Defaults to `true`.
//    var canBeNavigatedBackTo: Bool { get }
    
    /**
     Optional event method called when the coordinator has become the active coordinator for the currently presented
     view controller. This can be called anytime one of the coordinator's underlying view controllers becomes the
     actively shown view controller, such as when it is first presented, when a view controller is dismissed to it,
     or when the view controller's tab is switched to. This method is always called after the coordinator's
    `presentViewController` method.
     */
    func didBecomeActive()
    /**
     Optional event method called when a new coordinator is shown and this coordinator becomes inactive.
    */
    func didBecomeInactive()
    /// Optional event method called when the coordinator has been dismissed by the navigator.
    func didDismiss()
}

public extension BaseCoordinator {
    func didBecomeActive() { }
    
    func didBecomeInactive() { }
    
    func didDismiss() { }
    
    var canBeNavigatedBackTo: Bool {
        return true
    }
}



/**
 A basic protocol that all coordinator types implement. This is mostly used internally and should not be implemented on
 its own - instead, implement one of either `Coordinator`, `FlowCoordinator`, or `SelfCoordinating`.
 */
public protocol SetupModelRequiring {
    /// The type of the model object that contains all dependencies the coordinator needs to be properly initialized.
    /// Defaults to 'Void' if no explicit type is set.
    associatedtype SetupModel = Void
    
    /**
     Creates an instance of the coordinator. In the implemented method, the coordinator should be instantiated and
     configured with the given `model` object, which is an instance of its aliased `SetupModel` type. A basic
     implementation of this method is provided if the `SetupModel` type is `Void`.
     - parameter model: The context object containing all dependencies the view controller needs.
     - parameter navigator: The navigator the coordinator should use to navigate from.
     */
    static func create(with model: SetupModel, navigator: Navigator) -> Self
    
    init()
}

public extension SetupModelRequiring where Self.SetupModel == Void, Self: BaseCoordinator {
    static func create(with model: SetupModel, navigator: Navigator) -> Self {
        let coordinator = Self()
        coordinator.navigator = navigator
        return coordinator
    }
}

public extension SetupModelRequiring where Self: UIViewController, Self: BaseCoordinator, Self.SetupModel == Void {
    // NOTE: This default behaviour should be overriden for view controllers that must be initialized from storyboards.
    static func create(with model: SetupModel, navigator: Navigator) -> Self {
        let selfCoordinatingVC = Self(nibName: nil, bundle: nil)
        selfCoordinatingVC.navigator = navigator
        return selfCoordinatingVC
    }
}
