
import UIKit

/**
 A type-erased class representing any navigation coordinator with the same SetupContext type.
 
 This class will forward calls to its NavigationCoordinator requirements to an underlying coordinator passed
 into its init method, thus hiding the specifics of the underlying NavigationCoordinator. This underlying
 coordinator must have the same SetupContext type as the set generic type of this class.
 */
public final class AnyNavigationFlowCoordinator<SetupContext, CompletionContext>: NavigationFlowCoordinator {
    private let coordinatorWrapper: _AnyNavigationFlowCoordinatorBase<SetupContext, CompletionContext>
    
    public var flowDelegate: NavigationFlowCoordinatorDelegate? {
        get { return coordinatorWrapper.flowDelegate }
        set { coordinatorWrapper.flowDelegate = newValue }
    }
    
    public init<UnderlyingCoordinatorType: NavigationFlowCoordinator>(_ navigationCoordinator: UnderlyingCoordinatorType) where UnderlyingCoordinatorType.SetupContext == SetupContext, UnderlyingCoordinatorType.FlowCompletionContext == CompletionContext {
        self.coordinatorWrapper = _AnyNavigationFlowCoordinatorWrapper(navigationCoordinator)
    }
    
    public func start(with context: SetupContext, from fromVC: UIViewController) {
        return coordinatorWrapper.start(with: context, from: fromVC)
    }
}


/**
 A private abstract class providing stubs for NavigationCoordinator's requirements. This abstract class
 provides a supertype for the _AnyNavigationCoordinatorWrapper that takes the SetupContext as its generic
 so an _AnyNavigationCoordinatorWrapper instance can be created once the underlying coordinator's type is
 known in the AnyNavigationCoordinator's init method.
 */
fileprivate class _AnyNavigationFlowCoordinatorBase<GenericSetupContext, GenericCompletionContext>: NavigationFlowCoordinator {
    typealias SetupContext = GenericSetupContext
    typealias FlowCompletionContext = GenericCompletionContext
    
    var flowDelegate: NavigationFlowCoordinatorDelegate?
    
    init() {
        guard type(of: self) != _AnyNavigationFlowCoordinatorBase.self else {
            fatalError("_AnyNavigationCoordinatorBase instances can not be created; create a subclass instance instead.")
        }
    }

    func start(with context: GenericSetupContext, from fromVC: UIViewController) {
        fatalError("Must be overwritten.")
    }
}

/**
 A wrapper around a NavigationCoordinator object that relays all calls to its NavigationCoordinator requirements
 to this underlying object to implement type erasure.
 */
fileprivate final class _AnyNavigationFlowCoordinatorWrapper<UnderlyingCoordinatorType: NavigationFlowCoordinator>: _AnyNavigationFlowCoordinatorBase<UnderlyingCoordinatorType.SetupContext, UnderlyingCoordinatorType.FlowCompletionContext> {
    
    var underlyingCoordinator: UnderlyingCoordinatorType
    override var flowDelegate: NavigationFlowCoordinatorDelegate? {
        get { return underlyingCoordinator.flowDelegate }
        set { underlyingCoordinator.flowDelegate = newValue }
    }

    init(_ underlyingCoordinator: UnderlyingCoordinatorType) {
        self.underlyingCoordinator = underlyingCoordinator
    }

    override func start(with context: UnderlyingCoordinatorType.SetupContext, from fromVC: UIViewController) {
        return underlyingCoordinator.start(with: context, from: fromVC)
    }
}
