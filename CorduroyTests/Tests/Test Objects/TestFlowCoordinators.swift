
import XCTest
import Nimble
import Corduroy

// A basic test flow coordinator. Takes the view controller it should use as its first view controller via its SetupModel.
// Has a Void FlowResult.
final class TestFlowCoordinatorVoidCompletionModel: FlowCoordinator {
    typealias SetupModel = BaseTestController? //the VC to use as the first VC
    
    var navigator: Navigator!
    
    var firstViewController: BaseTestController?
    var navContext: NavigationContext!
    var flowCompletion: ((Error?, Void?) -> Void)!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with firstViewController: BaseTestController?, navigator: Navigator) -> TestFlowCoordinatorVoidCompletionModel {
        let coordinator = TestFlowCoordinatorVoidCompletionModel()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: NavigationContext, flowCompletion: @escaping (Error?, ()?) -> Void) {
        if let vc = self.firstViewController {
            vc.coordinator = self
            self.present(vc, context: context)
        }
        self.flowCompletion = flowCompletion
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}

// A test coordinator whose flow completion gives a string value as its FlowResult
final class TestFlowCoordinatorStringCompletionModel: FlowCoordinator {
    typealias SetupModel = BaseTestController? //the VC to use as the first VC
    typealias FlowResult = String
    
    var navigator: Navigator!
    
    var firstViewController: BaseTestController?
    var navContext: NavigationContext!
    var flowCompletion: ((Error?, String?) -> Void)!
    var createCallCount: Int = 0
    var presentFirstVCCallCount: Int = 0
    var onDismissalCallCount: Int = 0
    
    static func create(with firstViewController: BaseTestController?, navigator: Navigator) -> TestFlowCoordinatorStringCompletionModel {
        let coordinator = TestFlowCoordinatorStringCompletionModel()
        coordinator.navigator = navigator
        coordinator.firstViewController = firstViewController
        coordinator.createCallCount += 1
        return coordinator
    }
    
    func presentFirstViewController(context: NavigationContext, flowCompletion: @escaping (Error?, String?) -> Void) {
        if let vc = self.firstViewController {
            vc.coordinator = self
            self.present(vc, context: context)
        }
        self.flowCompletion = flowCompletion
        self.presentFirstVCCallCount += 1
        self.navContext = context
    }
    
    func onDismissal() {
        self.onDismissalCallCount += 1
    }
}
