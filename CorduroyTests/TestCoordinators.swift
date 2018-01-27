
import Foundation
import Corduroy

final class TestCoordinatorVoidSetup1: Coordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        
    }
}

final class TestCoordinatorVoidSetup2: Coordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        
    }
}

final class TestCoordinatorStringSetupContext: Coordinator {
    typealias SetupModel = (val1: String, val2: String)
    
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    static func create(with model: SetupModel, navigator: Navigator) -> TestCoordinatorStringSetupContext {
        let coordinator = TestCoordinatorStringSetupContext()
        coordinator.navigator = navigator
        return coordinator
    }
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        
    }
}




final class TestFlowCoordinatorVoidSetupVoidCompletion: FlowCoordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    var flowCompletion: ((Error?, Void?) -> Void)!
    
    func presentFirstViewController(context: Navigator.NavigationContext, flowCompletion: @escaping (Error?, ()?) -> Void) {
        self.flowCompletion = flowCompletion
    }
}
