
import XCTest
import Nimble
import Corduroy

// A basic test flow coordinator. Takes the view controller it should use as its first view controller via its SetupModel.
// Has a Void FlowCompletionModel.
final class TestFlowCoordinatorVoidCompletionModel: FlowCoordinator {
    final class TestViewController: UIViewController, CoordinatorManageable {
        var coordinator: TestFlowCoordinatorVoidCompletionModel?
    }
    
    typealias SetupModel = UIViewController? //the VC to use as the first VC
    
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var navContext: NavigationContext!
    var flowCompletion: ((Error?, Void?) -> Void)!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with firstViewController: UIViewController?, navigator: Navigator) -> TestFlowCoordinatorVoidCompletionModel {
        let coordinator = TestFlowCoordinatorVoidCompletionModel()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: NavigationContext, flowCompletion: @escaping (Error?, Void?) -> Void) {
        if let vc = self.firstViewController as? TestViewController {
            vc.coordinator = self
        }
        if let vc = self.firstViewController {
            self.present(vc, asDescribedBy: context)
        }
        self.flowCompletion = flowCompletion
        self.currentViewController = firstViewController
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}

// A test coordinator whose flow completion gives a string value as its FlowCompletionModel
final class TestFlowCoordinatorStringCompletionModel: FlowCoordinator {
    final class TestViewController: UIViewController, CoordinatorManageable {
        var coordinator: TestFlowCoordinatorStringCompletionModel?
    }
    
    typealias SetupModel = UIViewController? //the VC to use as the first VC
    typealias FlowCompletionModel = String
    
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    var firstViewController: UIViewController?
    var navContext: NavigationContext!
    var flowCompletion: ((Error?, String?) -> Void)!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with firstViewController: UIViewController?, navigator: Navigator) -> TestFlowCoordinatorStringCompletionModel {
        let coordinator = TestFlowCoordinatorStringCompletionModel()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: NavigationContext, flowCompletion: @escaping (Error?, String?) -> Void) {
        if let vc = self.firstViewController as? TestViewController {
            vc.coordinator = self
        }
        if let vc = self.firstViewController {
            self.present(vc, asDescribedBy: context)
        }
        self.flowCompletion = flowCompletion
        self.currentViewController = firstViewController
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}
