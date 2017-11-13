
import UIKit
import Coordinator

protocol LandingViewControllerCoordinator {
    func landingViewControllerDidPressLogin(_ viewController: LandingViewController)
}

final class LandingViewController: UIViewController, NavigationCoordinatorManageable {    
    private(set) var coordinator: LandingViewControllerCoordinator!
    
    static func create(with context: EmptyContext, coordinator: LandingViewControllerCoordinator) -> LandingViewController {
        let viewController = LandingViewController()
        viewController.coordinator = coordinator
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let startLoginButton = UIButton(type: .system)
        startLoginButton.setTitle("Login", for: .normal)
        startLoginButton.addTarget(self, action: #selector(startLoginPressed), for: .touchUpInside)
        
        startLoginButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func startLoginPressed(sender: UIButton) {
        self.coordinator.landingViewControllerDidPressLogin(self)
    }
}

