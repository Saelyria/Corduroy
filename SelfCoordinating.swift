
import Foundation

/**
 Describes a view controller that manages its own navigation logic.
 
 A view controller that's fairly simple and is highly coupled to its navigation logic can choose to coordinate itself
 by implementing this protocol. This view controller can then be treated like any other coordinator - it can be
 navigated to and from using a navigator, have preconditions for its navigation, and everything else that a coordinator
 is afforded.
 
 A self-coordinating view controller does not need to implement its `currentViewController` or `coordinator` properties;
 by default, these will both return `self`. It will still, however, have to implement the `create(with:)` and
 `start(context:)` methods found on `Coordinator`.
 */
protocol SelfCoordinating: Coordinator, CoordinatorManageable where ManagingCoordinator == Self { }

extension SelfCoordinating {
    var currentViewController: UIViewController {
        return self
    }
    
    var coordinator: Self? {
        return self
    }
}
