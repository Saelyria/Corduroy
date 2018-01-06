
import UIKit

/**
 A basic protocol that all coordinator types implement. This is mostly used internally and should not be implemented on
 its own - instead, implement one of either `Coordinator`, `FlowCoordinator`, or `SelfCoordinating`.
 */
public protocol BaseCoordinator {
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
    
    /**
     Creates an instance of the coordinator. In the implemented method, the coordinator should be instantiated and
     configured with the given `model` object, which is an instance of its aliased `SetupModel` type.
     - parameter model: The context object containing all dependencies the view controller needs.
     - parameter navigator: The navigator the coordinator should use to navigate from.
     */
    static func create(with model: SetupModel, navigator: Navigator) -> Self
    
    /**
     Starts the coordinator with the given navigation context. In this method, the coordinator should instantiate its
     first view controller and push/present it from the context's
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     */
    func start(context: Navigator.NavigationContext)
}
