
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
        
        let coordinator = AnyNavigationCoordinator(self)
        delegate?.navigationCoordinatorDidStart(coordinator)
    }
}

extension AppCoordinator: LandingViewControllerCoordinator {
    func landingViewControllerDidPressLogin(_ viewController: LandingViewController) {
        let signupFlowCoordinator = SignupFlowCoordinator()
        signupFlowCoordinator.flowDelegate = self
        signupFlowCoordinator.start(with: EmptyContext(), from: viewController)
    }
    
    func landingViewControllerDidPressTutorial(_ viewController: LandingViewController) {
        
    }
}

extension AppCoordinator: NavigationFlowCoordinatorDelegate {
    func flowNavigationCoordinator<SetupType, CompletionType>(_ coordinator: AnyNavigationFlowCoordinator<SetupType, CompletionType>, didFinishWithContext completionContext: CompletionType, from fromVC: UIViewController) {
        if let signupInfo = completionContext as? SignupInfo {
            fromVC.dismiss(animated: true, completion: nil)
        }
    }
}
