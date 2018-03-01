
import UIKit

/**
 A protocol describing an object that manages navigation logic.
 
 A coordinator object is responsible for managing the navigation between view controllers, containing all navigation
 logic within itself. Coordinators should act as delegates for actions in view controllers (such as a button press or
 other action the user performed) that would trigger navigation to a new view controller. Navigation in the application
 should be thought of as navigation between coordinators (where the coordinators are thought of as a specific 'section'
 or 'screen' of an app) instead of between view controllers; this way, a view controller can remain a controller just of
 its view (thus allowing them to be much more reusable) and coordinators can choose between different view controllers
 to display without the outer application knowing. Generally, a coordinator will manage one view controller then maybe
 any view controllers that aid that view controller in its task, like a modal error screen or dropdown list. They should
 generally represent a unique location in your app.
 
 Dependencies for a coordinator can be defined via its `SetupModel` associated type. An object of this type is passed
 in to the `create(with:navigator:)` factory method of the coordinator. Beyond this setup model, there should be little
 to no more communication between coordinators - the idea is that a coordinator's setup model includes everything it
 needs from the outer application to do its job. This `SetupModel` associated type defaults to `Nothing` if no explicit
 type is set. Note that coordinators are instantiated with their class's `create(with:navigator:)` methods, so `init`
 methods shouldn't be implemented.
 */
public protocol Coordinator: BaseCoordinator, SetupModelRequiring {
    /**
     Called when the coordinator is navigated to. In this method, the coordinator should instantiate its first view
     controller and push/present it from the context's `currentViewController`.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     */
    func presentFirstViewController(context: NavigationContext)
}



/**
 A protocol describing an object that manages navigation in a user flow.
 
 A flow coordinator is a specialized navigation coordinator that is responsible for a set of view controllers in a user
 'flow'. A user flow is any series of view controllers that are launched with the intention of completing a specific
 task or returning a specific value; for example, starting a flow to have the user authenticate or starting a flow to
 upload a picture. Flows have a defined start and end.
 
 Flow coordinators are started by other coordinators and are expected to, once completed, call the completion closure
 passed into their `start(context:completion:)` method where they will pass in either an error if their flow 'failed' or
 a completion context of their `FlowCompletionModel` type. This context type could be, as in the example of
 authentication, a type that contains information about whether the authentication was successful and, if so, the
 credentials for the authentication.
 */
public protocol FlowCoordinator: BaseCoordinator, SetupModelRequiring {
    /// The type of the model object that this flow coordinator will return in its completion containing data about or
    /// as a result of its flow. Defaults to 'Nothing' if no explicit type is set.
    associatedtype FlowCompletionModel = Nothing
    
    /**
     Called when the flow coordinator is navigated to. In this method, the coordinator should instantiate its first view
     controller and push/present it from the context's `currentViewController`.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     - parameter flowCompletion: A closure to call after the flow has completed.
     */
    func presentFirstViewController(context: NavigationContext, flowCompletion: @escaping (Error?, FlowCompletionModel?) -> Void)
}



/**
 A basic protocol that all coordinator types implement. This is mostly used internally and should not be implemented on
 its own - instead, implement one of either `Coordinator`, `FlowCoordinator`, or `SelfCoordinating`.
 */
public protocol BaseCoordinator: AnyObject {
    /// The navigator managing navigation to this coordinator and that it should use to perform navigation to other
    /// coordinators.
    var navigator: Navigator! { get set }
    
    /// The view controller the coordinator is currently presenting and managing. This must be set by the coordinator
    /// whenever it changes the currently presented view controller.
    var currentViewController: UIViewController? { get }
    
    /// Whether this coordinator can be navigated back to (i.e. if it should be skipped over when its navigator's
    /// `goBack(to:)` method is called). This can be useful, for example, for precondition recovering flow coordinators
    /// or login view controllers after a user has logged in. Defaults to `true`.
    var canBeNavigatedBackTo: Bool { get }
    
    /**
     Called when the navigator wants to dismiss the view controller(s) managed by this coordinator. In this method, the
     coordinator should dismiss any view controllers it is managing. A default implementation is provided.
     
     Note that this method may not always be called on the coordinator on its dismissal; the main case for when this
     method is not called is when navigation back is done by a `UINavigationController`, in which case dismissal of the
     view controller is handled by the navigation controller.
     - parameter context: A context object containing details about the navigation, such as the involved coordinators.
     */
    func dismissViewControllers(context: NavigationContext)
    
    /**
     Optional event method called when the navigator has been dismissed by the navigator or by a navigation controller.
     */
    func onDismissal()
    
    /**
     Optional event method called when the navigator has started evaluating an asynchronous precondition on a navigation
     started by this coordinator. This method can be used to start tasks indicating to the user that an asynchronous
     task has started, such as starting a loading indicator.
     */
    func onPreconditionRecoveryStarted()
}

public extension BaseCoordinator {
    func onDismissal() { }
    
    func onPreconditionRecoveryStarted() { }
    
    var canBeNavigatedBackTo: Bool {
        return true
    }
    
    func dismissViewControllers(context: NavigationContext) {
        UIViewController.dismissCurrentViewController(in: context)
    }
}

/**
 A basic protocol that all coordinator types implement. This is mostly used internally and should not be implemented on
 its own - instead, implement one of either `Coordinator`, `FlowCoordinator`, or `SelfCoordinating`.
 */
public protocol SetupModelRequiring {
    /// The type of the model object that contains all dependencies the coordinator needs to be properly initialized.
    /// Defaults to 'Nothing' if no explicit type is set.
    associatedtype SetupModel = Nothing
    
    /**
     Creates an instance of the coordinator. In the implemented method, the coordinator should be instantiated and
     configured with the given `model` object, which is an instance of its aliased `SetupModel` type. A basic
     implementation of this method is provided if the `SetupModel` type is `Nothing`.
     - parameter model: The context object containing all dependencies the view controller needs.
     - parameter navigator: The navigator the coordinator should use to navigate from.
     */
    static func create(with model: SetupModel, navigator: Navigator) -> Self
    
    init()
}

public extension SetupModelRequiring where Self.SetupModel == Nothing, Self: BaseCoordinator {
    static func create(with model: SetupModel, navigator: Navigator) -> Self {
        let coordinator = Self()
        coordinator.navigator = navigator
        return coordinator
    }
}

/**
 An empty struct that is used as the default value of `SetupModel` or `FlowCompletionModel` associated types.
 Coordinators whose setup models are this type are taken to mean that they have no dependencies.
 */
public struct Nothing: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {  }
}


