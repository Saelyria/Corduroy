
import XCTest
import Nimble
import Corduroy

final class TestCoordinator: Coordinator {
    typealias SetupModel = UIViewController? //the VC to use as the first VC

    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var navContext: Navigator.NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    
    static func create(with firstViewController: UIViewController?, navigator: Navigator) -> TestCoordinator {
        let coordinator = TestCoordinator()
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        if let vc = self.firstViewController {
            context.currentViewController.present(vc, context: context)
        }
        self.currentViewController = firstViewController
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
}

// a copy of 'TestCoordinator' for type difference testing
final class TestCoordinator2: Coordinator {
    typealias SetupModel = UIViewController? //the VC to use as the first VC
    
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var navContext: Navigator.NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    
    static func create(with firstViewController: UIViewController?, navigator: Navigator) -> TestCoordinator2 {
        let coordinator = TestCoordinator2()
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        if let vc = self.firstViewController {
            context.currentViewController.present(vc, context: context)
        }
        self.currentViewController = firstViewController
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
}

final class TestCoordinatorVoidSetup: Coordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var testFirstViewController: UIViewController?
    var navContext: Navigator.NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    
    static func create(with: (), navigator: Navigator) -> TestCoordinatorVoidSetup {
        let coordinator = TestCoordinatorVoidSetup()
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
}

final class TestCoordinatorStringSetup: Coordinator {
    typealias SetupModel = (firstVC: UIViewController, string: String)
    
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var setupString: String!
    var navContext: Navigator.NavigationContext!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    
    static func create(with model: SetupModel, navigator: Navigator) -> TestCoordinatorStringSetup {
        let coordinator = TestCoordinatorStringSetup()
        coordinator.navigator = navigator
        coordinator.firstViewController = model.firstVC
        coordinator.createCallCount += 1
        coordinator.setupString = model.string
        return coordinator
    }
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        if let vc = self.firstViewController {
            context.currentViewController.present(vc, context: context)
        }
        self.currentViewController = firstViewController
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
}

final class TestPassingPreconditionRequiringCoordinator: Coordinator, NavigationPreconditionRequiring {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var presentFirstVCCallCount: Int = 0
    
    static var preconditions: [NavigationPrecondition.Type] {
        return [PassingPrecondition.self]
    }
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        self.presentFirstVCCallCount += 1
    }
    
    func present(viewController: UIViewController) {
        self.currentViewController?.present(viewController, by: .modallyPresenting)
    }
}
