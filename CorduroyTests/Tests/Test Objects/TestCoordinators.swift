
import XCTest
import Nimble
import Corduroy

class BaseTestController: UIViewController {
    var coordinator: Any?
}

class TestViewController: BaseTestController { }

class TestEmbeddedViewController: BaseTestController, NavigationControllerEmbedded { }

// A basic test coordinator. Takes the view controller it should use as its first view controller via its SetupModel.
final class TestCoordinator: Coordinator {
    typealias SetupModel = BaseTestController? //the VC to use as the first VC

    var navigator: Navigator!
    
    var firstViewController: BaseTestController?
    var navContext: NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with firstViewController: BaseTestController?, navigator: Navigator) -> TestCoordinator {
        let coordinator = TestCoordinator()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentViewController(presentMethod: PresentMethod, context: NavigationContext) {
        if let vc = self.firstViewController {
            vc.coordinator = self
            self.present(vc, by: presentMethod, context: context)
        }
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}

// A test coordinator that takes its first view controller and a string as its setup model
final class TestCoordinatorStringSetup: Coordinator {
    typealias SetupModel = (firstVC: BaseTestController?, string: String)
    
    var navigator: Navigator!
    
    var firstViewController: BaseTestController?
    var setupString: String!
    var navContext: NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with model: SetupModel, navigator: Navigator) -> TestCoordinatorStringSetup {
        let coordinator = TestCoordinatorStringSetup()
        coordinator.navigator = navigator
        coordinator.firstViewController = model.firstVC
        coordinator.createCallCount += 1
        coordinator.setupString = model.string
        return coordinator
    }
    
    func presentViewController(presentMethod: PresentMethod, context: NavigationContext) {
        if let vc = self.firstViewController {
            vc.coordinator = self
            self.present(vc, by: presentMethod, context: context)
        }
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}

final class TestPassingPreconditionRequiringCoordinator: Coordinator, NavigationPreconditionRequiring {
    static var preconditions: [NavigationPrecondition.Type] {
        return [PassingPrecondition.self, PassingPrecondition.self]
    }
    
    typealias SetupModel = BaseTestController?
    
    var navigator: Navigator!
    
    var firstViewController: BaseTestController?
    var navContext: NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with firstViewController: BaseTestController?, navigator: Navigator) -> TestPassingPreconditionRequiringCoordinator {
        let coordinator = TestPassingPreconditionRequiringCoordinator()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentViewController(presentMethod: PresentMethod, context: NavigationContext) {
        if let vc = self.firstViewController {
            vc.coordinator = self
            self.present(vc, by: presentMethod, context: context)
        }
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}
