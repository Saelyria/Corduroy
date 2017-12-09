
import Foundation
import Coordinator

class AppCoordinator: Coordinator {
    var delegate: CoordinatorDelegate?
    
    func start(with context: EmptyContext, from fromVC: UIViewController) {
        let viewController = LandingViewController.create(with: EmptyContext(), coordinator: self)
        
        fromVC.addChildViewController(viewController)
        fromVC.view.addSubview(viewController.view)
        viewController.view.frame = fromVC.view.frame
        viewController.didMove(toParentViewController: fromVC)
    }
}

extension AppCoordinator: LandingViewControllerCoordinator {
    func landingViewControllerDidPressLogin(_ viewController: LandingViewController) {
        let signupFlowCoordinator = SignupFlowCoordinator()
        signupFlowCoordinator.start(with: EmptyContext(), from: viewController)
    }
    
    func landingViewControllerDidPressTutorial(_ viewController: LandingViewController) {
        
    }
}

extension AppCoordinator: FlowCoordinatorDelegate {
    func coordinatorDidCompleteFlow<CoordinatorType: FlowCoordinator>(_ coordinator: CoordinatorType, fromVC: UIViewController, context: CoordinatorType.FlowCompletionContext) {
        fromVC.dismiss(animated: true, completion: nil)
    }
}
