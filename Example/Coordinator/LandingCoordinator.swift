
import Foundation
import Coordinator

class LandingCoordinator: Coordinator {
    var currentViewController: UIViewController?
        
    func start(with model: (), context: Navigator.NavigationContext) {
        let viewController = LandingViewController()
        viewController.coordinator = self
        
        context.currentViewController.addChildViewController(viewController)
        context.currentViewController.view.addSubview(viewController.view)
        viewController.view.frame = context.currentViewController.view.frame
        viewController.didMove(toParentViewController: context.currentViewController)
    }

    func landingViewControllerDidPressLogin(_ viewController: LandingViewController) {
        let signupFlowCoordinator = SignupFlowCoordinator()
        AppDelegate.navigator.navigate(to: signupFlowCoordinator, by: .present) { (error, signupInfo) in
            
        }
    }
    
    func landingViewControllerDidPressTutorial(_ viewController: LandingViewController) {
        
    }
}
