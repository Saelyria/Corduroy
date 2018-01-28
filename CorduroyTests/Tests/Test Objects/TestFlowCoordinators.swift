
import XCTest
import Nimble
import Corduroy

protocol TestFlowCoordinator: FlowCoordinator {
    var testFirstViewController: UIViewController? { get set }
}

final class TestFlowCoordinatorVoidSetupVoidCompletion: TestFlowCoordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    var testFirstViewController: UIViewController?
    var flowCompletion: ((Error?, Void?) -> Void)!
    
    func presentFirstViewController(context: Navigator.NavigationContext, flowCompletion: @escaping (Error?, ()?) -> Void) {
        self.flowCompletion = flowCompletion
    }
}

final class TestFlowCoordinatorVoidSetupStringCompletion: TestFlowCoordinator {
    typealias CompletionModel = (String, String)
    
    var navigator: Navigator!
    var currentViewController: UIViewController?
    var testFirstViewController: UIViewController?
    var flowCompletion: ((Error?, (String, String)?) -> Void)!
    
    func presentFirstViewController(context: Navigator.NavigationContext, flowCompletion: @escaping (Error?, (String, String)?) -> Void) {
        self.flowCompletion = flowCompletion
    }
}

