
import UIKit

public protocol BaseCoordinator {
    var currentViewController: UIViewController? { get }
}

/**
 A protocol describing an object that manages navigation between view controllers.
 
 A coordinator object is responsible for managing the navigation between view controllers, containing all navigation
 logic within itself. Coordinators should act as delegates for actions in view controllers (such as a button press or
 other action the user performed) that would trigger navigation to a new view controller.
 
 Dependencies for a coordinator can be defined via its `SetupModel` associated type. An object of this type is passed
 in to the `start(context:from:)` method of the coordinator to have the coordinator present its first view controller
 from the given view controller. This `SetupModel` associated type defaults to `Void` if no explicit type is set.
 */
public protocol Coordinator: BaseCoordinator {
    /// The type of the model object that contains all dependencies the coordinator needs to be properly initialized.
    /// Defaults to 'Void' if no explicit type is set.
    associatedtype SetupModel = Void
    
    /**
     Starts the coordinator with the given setup model and navigation context.
     - parameter model: The model object containing all dependencies the coordinator needs.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     */
    func start(with model: SetupModel, context: Navigator.NavigationContext)
}

public extension Coordinator where Self.SetupModel == Void {
    /**
     Starts the coordinator with the given navigation context.
     - parameter context: A context object containing the involved coordinators and the view controller to start from.
     */
    func start(context: Navigator.NavigationContext) {
        self.start(with: (), context: context)
    }
}
