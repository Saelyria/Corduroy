
import XCTest
import Nimble
import Corduroy

// A basic test coordinator. Takes the view controller it should use as its first view controller via its SetupModel.
final class TestCoordinator: Coordinator {
    final class TestViewController: UIViewController, CoordinatorManageable {
        var coordinator: TestCoordinator?
    }
    
    typealias SetupModel = UIViewController? //the VC to use as the first VC

    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var navContext: Navigator.NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with firstViewController: UIViewController?, navigator: Navigator) -> TestCoordinator {
        let coordinator = TestCoordinator()
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        if let vc = self.firstViewController as? TestViewController {
            vc.coordinator = self
        }
        if let vc = self.firstViewController {
            UIViewController.present(vc, asDescribedBy: context)
        }
        self.currentViewController = firstViewController
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}

// A test coordinator that takes its first view controller and a string as its setup model
final class TestCoordinatorStringSetup: Coordinator {
    final class TestViewController: UIViewController, CoordinatorManageable {
        var coordinator: TestCoordinatorStringSetup?
    }
    
    typealias SetupModel = (firstVC: UIViewController?, string: String)
    
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var setupString: String!
    var navContext: Navigator.NavigationContext!
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
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        if let vc = self.firstViewController as? TestViewController {
            vc.coordinator = self
        }
        if let vc = self.firstViewController {
            UIViewController.present(vc, asDescribedBy: context)
        }
        self.currentViewController = firstViewController
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}

final class TestPassingPreconditionRequiringCoordinator: Coordinator, NavigationPreconditionRequiring {
    final class TestViewController: UIViewController, CoordinatorManageable {
        var coordinator: TestPassingPreconditionRequiringCoordinator?
    }
    
    static var preconditions: [NavigationPrecondition.Type] {
        return [PassingPrecondition.self, PassingPrecondition.self]
    }
    
    typealias SetupModel = UIViewController?
    
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var navContext: Navigator.NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with firstViewController: UIViewController?, navigator: Navigator) -> TestPassingPreconditionRequiringCoordinator {
        let coordinator = TestPassingPreconditionRequiringCoordinator()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        if let vc = self.firstViewController as? TestViewController {
            vc.coordinator = self
        }
        if let vc = self.firstViewController {
            UIViewController.present(vc, asDescribedBy: context)
        }
        self.currentViewController = firstViewController
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}
