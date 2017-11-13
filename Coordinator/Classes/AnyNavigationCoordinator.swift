
import UIKit

/**
 A type-erased class representing any navigation coordinator with the same SetupContext type.
 
 This class will forward calls to its NavigationCoordinator requirements to an underlying coordinator passed
 into its init method, thus hiding the specifics of the underlying NavigationCoordinator. This underlying
 coordinator must have the same SetupContext type as the set generic type of this class.
 */
final class AnyNavigationCoordinator<SetupContext>: NavigationCoordinator {
    private let coordinatorWrapper: _AnyNavigationCoordinatorBase<SetupContext>
    var delegate: NavigationCoordinatorDelegate? {
        get { return coordinatorWrapper.delegate }
        set { coordinatorWrapper.delegate = newValue }
    }
    
    init<UnderlyingCoordinatorType: NavigationCoordinator>(_ navigationCoordinator: UnderlyingCoordinatorType) where UnderlyingCoordinatorType.SetupContext == SetupContext {
        self.coordinatorWrapper = _AnyNavigationCoordinatorWrapper(navigationCoordinator)
    }
    
    func start(with context: SetupContext, from fromVC: UIViewController) {
        return coordinatorWrapper.start(with: context, from: fromVC)
    }    
}


/**
 A private abstract class providing stubs for NavigationCoordinator's requirements. This abstract class
 provides a supertype for the _AnyNavigationCoordinatorWrapper that takes the SetupContext as its generic
 so an _AnyNavigationCoordinatorWrapper instance can be created once the underlying coordinator's type is
 known in the AnyNavigationCoordinator's init method.
*/
fileprivate class _AnyNavigationCoordinatorBase<SetupContext>: NavigationCoordinator {
    var delegate: NavigationCoordinatorDelegate?
    
    init() {
        guard type(of: self) != _AnyNavigationCoordinatorBase.self else {
            fatalError("_AnyNavigationCoordinatorBase instances can not be created; create a subclass instance instead.")
        }
    }

    func start(with context: SetupContext, from fromVC: UIViewController) {
        fatalError("Must be overriden by a subclass.")
    }
}

/**
 A wrapper around a NavigationCoordinator object that relays all calls to its NavigationCoordinator requirements
 to this underlying object to implement type erasure.
*/
fileprivate final class _AnyNavigationCoordinatorWrapper<UnderlyingCoordinatorType: NavigationCoordinator>: _AnyNavigationCoordinatorBase<UnderlyingCoordinatorType.SetupContext> {
    var underlyingCoordinator: UnderlyingCoordinatorType
    override var delegate: NavigationCoordinatorDelegate? {
        get { return underlyingCoordinator.delegate }
        set { underlyingCoordinator.delegate = newValue }
    }

    init(_ underlyingCoordinator: UnderlyingCoordinatorType) {
        self.underlyingCoordinator = underlyingCoordinator
    }

    override func start(with context: SetupContext, from fromVC: UIViewController) {
        return underlyingCoordinator.start(with: context, from: fromVC)
    }
}
