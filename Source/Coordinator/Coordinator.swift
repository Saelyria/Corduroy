
import UIKit

/**
 A basic protocol that all coordinator types implement. This is mostly used internally and should not be implemented on
 its own - instead, implement one of either `Coordinator`, `FlowCoordinator`, or `SelfCoordinating`.
 */
public protocol BaseCoordinator: AnyObject {
    /// The view controller the coordinator is currently presenting and managing. This must be set by the coordinator
    /// whenever it changes the currently presented view controller.
    var currentViewController: UIViewController? { get }
}



/**
 A protocol describing an object that manages navigation logic.
 
 A coordinator object is responsible for managing the navigation between view controllers, containing all navigation
 logic within itself. Coordinators should act as delegates for actions in view controllers (such as a button press or
 other action the user performed) that would trigger navigation to a new view controller. Navigation in the application
 should be thought of as navigation between coordinators (where the coordinators are thought of as a specific 'section'
 or 'screen' of an app) instead of between view controllers; this way, a view controller can remain a controller just of
 its view (thus allowing them to be much more reusable) and coordinators can choose between different view controllers
 to display without the outer application knowing. Generally, a coordinator will manage one view controller then maybe
 any view controller that aid that view controller in its task, like a modal error screen or dropdown list.
 
 Dependencies for a coordinator can be defined via its `SetupModel` associated type. An object of this type is passed
 in to the `create(with:)` factory method of the coordinator. Beyond this setup model, there should be little to no more
 communication between coordinators - the idea is that a coordinator's setup model includes everything it needs from the
 outer application to do its job. This `SetupModel` associated type defaults to `Void` if no explicit type is set.
 */
public protocol Coordinator: BaseCoordinator {
    /// The type of the model object that contains all dependencies the coordinator needs to be properly initialized.
    /// Defaults to 'Void' if no explicit type is set.
    associatedtype SetupModel = Void
    
    var navigator: Navigator! { get set }
    
    /**
     Creates an instance of the coordinator. In the implemented method, the coordinator should be instantiated and
     configured with the given `model` object, which is an instance of its aliased `SetupModel` type.
     - parameter model: The context object containing all dependencies the view controller needs.
     - parameter navigator: The navigator the coordinator should use to navigate from.
     */
    static func create(with model: SetupModel, navigator: Navigator) -> Self
    
    init()
    
    /**
     Called when the coordinator is navigated to. In this method, the coordinator should instantiate its first view
     controller and push/present it from the context's `currentViewController`.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     */
    func start(context: Navigator.NavigationContext)
    
    /**
     Called when the coordinator is being navigated away from.
     - parameter context: A context object containing the involved coordinators.
     */
    func dismiss(context: Navigator.NavigationContext)
}

public extension Coordinator where Self.SetupModel == Void {
    static func create(with model: SetupModel, navigator: Navigator) -> Self {
        let coordinator = Self()
        coordinator.navigator = navigator
        return coordinator
    }
    
    func dismiss(context: Navigator.NavigationContext) { }
}



/**
 A protocol describing an object that manages navigation in a user flow.
 
 A flow coordinator is a specialized navigation coordinator that is responsible for a set of view controllers in a user
 'flow'. A user flow is any series of view controllers that are launched with the intention of completing a specific
 task or returning a specific value; for example, starting a flow to have the user authenticate or starting a flow to
 upload a picture. Flows have a defined start and end.
 
 Flow coordinators are started by other coordinators and are expected to, once completed, call the completion closure
 passed into their `start(context:completion:)` method where they will pass in either an error if their flow 'failed' or
 a completion context of their `FlowCompletionContext` type. This context type could be, as in the example of
 authentication, a type that contains information about whether the authentication was successful and, if so, the
 credentials for the authentication.
 */
public protocol FlowCoordinator: BaseCoordinator {
    /// The type of the model object that contains all dependencies the coordinator needs to be properly initialized.
    /// Defaults to 'Void' if no explicit type is set.
    associatedtype SetupModel = Void
    
    /// The type of the model object that this flow coordinator will return in its completion containing data about or
    /// as a result of its flow. Defaults to 'EmptyContext' if no explicit type is set.
    associatedtype FlowCompletionContext = Void
    
    // TODO: implement this and all the other stuff (like reference to view controllers) that this would require.
    var shouldBeRemovedFromNavStackOnCompletion: Bool { get }
    
    var navigator: Navigator! { get set }
    
    init()
    
    /**
     Creates an instance of the coordinator. In the implemented method, the coordinator should be instantiated and
     configured with the given `model` object, which is an instance of its aliased `SetupModel` type.
     - parameter model: The context object containing all dependencies the view controller needs.
     - parameter navigator: The navigator the coordinator should use to navigate from.
     */
    static func create(with model: SetupModel, navigator: Navigator) -> Self
    
    /**
     Starts the coordinator with the given setup model, navigation context, and flow completion handler. Called when the
     coordinator is being navigated to.
     - parameter model: The model object containing all dependencies the coordinator needs.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     - parameter completion: A closure to call after the flow has completed.
     */
    func start(context: Navigator.NavigationContext, completion: @escaping (Error?, FlowCompletionContext?) -> Void)
    
    func dismiss(context: Navigator.NavigationContext)
}

public extension FlowCoordinator {
    var shouldBeRemovedFromNavStackOnCompletion: Bool {
        return true
    }
}

public extension FlowCoordinator where Self.SetupModel == Void {
    static func create(with model: SetupModel, navigator: Navigator) -> Self {
        let coordinator = Self()
        coordinator.navigator = navigator
        return coordinator
    }
    
    func dismiss(context: Navigator.NavigationContext) { }
}


