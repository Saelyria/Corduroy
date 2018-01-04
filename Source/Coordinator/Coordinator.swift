
import UIKit

public protocol BaseCoordinator {
    static var preconditions: [NavigationPrecondition] { get }
    
    var currentViewController: UIViewController? { get }
}

public extension BaseCoordinator {
    static var preconditions: [NavigationPrecondition] {
        return []
    }
}


/**
 A protocol describing an object that manages navigation between view controllers.
 
 A coordinator object is responsible for managing the navigation between view controllers,
 containing all navigation logic within itself. Coordinators should act as delegates for
 actions in view controllers (such as a button press or other action the user performed)
 that would trigger navigation to a new view controller.
 
 Dependencies for a coordinator can be defined via its `SetupContext` associated type.
 An object of this type is passed in to the `start(context:from:)` method of the
 coordinator to have the coordinator present its first view controller from the given
 view controller. This `SetupContext` associated type defaults to `Void` if no
 explicit type is set.
 */
public protocol Coordinator: BaseCoordinator {
    /// The type of the model object that contains all dependencies the coordinator needs
    /// to be properly initialized. Defaults to 'Void' if no explicit type is set.
    associatedtype SetupContext = Void
    
    /**
     Starts the coordinator from the given view controller.
     - parameter context: The context object containing all dependencies the coordinator needs.
     - parameter fromVC: The view controller the coordinator should start its navigation from.
     */
    func start(with context: SetupContext, from fromVC: UIViewController)
}

public extension Coordinator where Self.SetupContext == Void {
    /**
     Starts the coordinator from the given view controller.
     - parameter fromVC: The view controller the coordinator should start its navigation from.
     */
    func start(from fromVC: UIViewController) {
        self.start(with: (), from: fromVC)
    }
}
