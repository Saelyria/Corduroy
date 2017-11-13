
import UIKit
import Coordinator

class LoginFlowCoordinator: NavigationFlowCoordinator {
    var flowDelegate: NavigationFlowCoordinatorDelegate?
    
    func start(with context: EmptyContext, from fromVC: UIViewController) {
        let createLoginVC = CreateLoginViewController.create(with: EmptyContext(), coordinator: self)
        fromVC.present(createLoginVC, animated: true, completion: nil)
    }
}
