
import Foundation
import Coordinator

class AppCoordinator: NavigationCoordinator {
    var delegate: NavigationCoordinatorDelegate?
    
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

extension AppCoordinator: NavigationFlowCoordinatorDelegate {
    func coordinatorDidCompleteFlow<CoordinatorType: NavigationFlowCoordinator>(_ coordinator: CoordinatorType, from fromVC: UIViewController, with context: CoordinatorType.FlowCompletionContextType) {
        fromVC.dismiss(animated: true, completion: nil)
    }
}
