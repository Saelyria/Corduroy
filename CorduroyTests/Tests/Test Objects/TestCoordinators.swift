import XCTest
import Nimble
import Corduroy

class BaseTestController: UIViewController {
    var coordinator: BaseCoordinator?
}

class TestViewController: BaseTestController { }

class TestEmbeddedViewController: BaseTestController, NavigationControllerEmbedded { }

class BaseTestCoordinator {
    fileprivate(set) var didBecomeActiveCallCount: Int = 0
    fileprivate(set) var didBecomeInactiveCallCount: Int = 0
    fileprivate(set) var didDismissCallCount: Int = 0
    
    func didBecomeActive(context: NavigationContext) {
        self.didBecomeActiveCallCount += 1
    }
    
    func didBecomeInactive(context: NavigationContext) {
        self.didBecomeInactiveCallCount += 1
    }
    
    func didDismiss(context: NavigationContext) {
        self.didDismissCallCount += 1
    }
}

// A basic test coordinator. Takes the view controller it should use as its first view controller via its SetupModel.
final class TestCoordinator: BaseTestCoordinator, Coordinator {
    typealias SetupModel = BaseTestController? //the VC to use as the first VC

    var navigator: Navigator!
    
    private(set) var firstViewController: BaseTestController?
    private(set) var navContext: NavigationContext!
    private(set) var createCallCount: Int = 0
    private(set) var presentFirstVCCallCount: Int = 0

    static func create(with firstViewController: BaseTestController?, navigator: Navigator) -> TestCoordinator {
        let coordinator = TestCoordinator()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentViewController(context: NavigationContext) {
        if let vc = self.firstViewController {
            vc.coordinator = self
            self.present(vc, context: context)
        }
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
}

// A test coordinator that takes its first view controller and a string as its setup model
final class TestCoordinatorStringSetup: BaseTestCoordinator, Coordinator {
    typealias SetupModel = (firstVC: BaseTestController?, string: String)
    
    var navigator: Navigator!
    
    private(set) var firstViewController: BaseTestController?
    private(set) var setupString: String!
    private(set) var navContext: NavigationContext!
    private(set) var createCallCount: Int = 0
    private(set) var presentFirstVCCallCount: Int = 0
    
    static func create(with model: SetupModel, navigator: Navigator) -> TestCoordinatorStringSetup {
        let coordinator = TestCoordinatorStringSetup()
        coordinator.navigator = navigator
        coordinator.firstViewController = model.firstVC
        coordinator.createCallCount += 1
        coordinator.setupString = model.string
        return coordinator
    }
    
    func presentViewController(context: NavigationContext) {
        if let vc = self.firstViewController {
            vc.coordinator = self
            self.present(vc, context: context)
        }
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
}

final class TestPassingPreconditionRequiringCoordinator: BaseTestCoordinator, Coordinator, NavigationPreconditionRequiring {
    static var preconditions: [NavigationPrecondition] {
        return [PassingPrecondition(), PassingPrecondition()]
    }
    
    typealias SetupModel = BaseTestController?
    
    var navigator: Navigator!
    
    private(set) var firstViewController: BaseTestController?
    private(set) var navContext: NavigationContext!
    private(set) var createCallCount: Int = 0
    private(set) var presentFirstVCCallCount: Int = 0

    
    static func create(with firstViewController: BaseTestController?, navigator: Navigator) -> TestPassingPreconditionRequiringCoordinator {
        let coordinator = TestPassingPreconditionRequiringCoordinator()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentViewController(context: NavigationContext) {
        if let vc = self.firstViewController {
            vc.coordinator = self
            self.present(vc, context: context)
        }
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
}
