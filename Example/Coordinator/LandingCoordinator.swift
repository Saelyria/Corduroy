
import Foundation
import Coordinator

class LandingCoordinator: Coordinator {
    var currentViewController: UIViewController?
        
    func start(with context: Void, from fromVC: UIViewController) {
        let viewController = LandingViewController.create(coordinator: self)
        
        fromVC.addChildViewController(viewController)
        fromVC.view.addSubview(viewController.view)
        viewController.view.frame = fromVC.view.frame
        viewController.didMove(toParentViewController: fromVC)
    }

    func landingViewControllerDidPressLogin(_ viewController: LandingViewController) {
        let signupFlowCoordinator = SignupFlowCoordinator()
        signupFlowCoordinator.startFlow(from: viewController) { (error, signupInfo) in
            
        }
    }
    
    func landingViewControllerDidPressTutorial(_ viewController: LandingViewController) {
        
    }
}
