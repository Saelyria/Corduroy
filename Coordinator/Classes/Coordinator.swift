
import UIKit

/**
 @brief A protocol describing an object that manages the flow between view controllers.
 
 @description A coordinator object is responsible for managing the navigation between its
 assigned view controllers, including containing all navigation logic within itself. A
 coordinator object is meant to be used for one specific user 'flow' - for example, the flow
 for a user login. The coordinator should be set up with a storyboard object that contains all
 of the view controllers it should manage. When its flow has been finished, it hands off app
 flow to the next coordinator.
*/
protocol FlowCoordinator {
    var storyboard: UIStoryboard { get }
}


/**
 @brief A protocol to be implemented by view controllers wishing to be managed by a coordinator.
 
 @description A view controller implementing this protocol should be managed by a Coordinator object.
*/
protocol CoordinatorManageable where Self: UIViewController {
    var coordinator: FlowCoordinator! { get set }
}


/**
 @brief A protocol allowing a view controller to define dependencies it expects from its coordinator.
 
 @description A view controller implementing this protocol should not implement its own init
 methods; instead, it should provide an associated 'CoordinatorConfiguration' class that should
 include all dependencies it needs to be initialized properly. The coordinator will call this
 configuration method with an instance of the view controller's defined configuration model when
 the managed view controller is being presented.
*/
protocol CoordinatorConfigurable: CoordinatorManageable {
    associatedtype CoordinatorConfiguration

    func configure(with model: CoordinatorConfiguration)
}
