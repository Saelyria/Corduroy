
import Foundation
import Coordinator

class AppCoordinator: NavigationCoordinator {    
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
        signupFlowCoordinator.startFlow(with: EmptyContext(), from: viewController) { (coordinator, fromVC, signupInfo) in
            fromVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func landingViewControllerDidPressTutorial(_ viewController: LandingViewController) {
        
    }
}
