
import UIKit
import Coordinator

final class CreateLoginViewController: UIViewController, NavigationCoordinatorManageable {
    var coordinator: LoginFlowCoordinator!
    
    static func create(with context: EmptyContext, coordinator: LoginFlowCoordinator) -> CreateLoginViewController {
        let createLoginVC = CreateLoginViewController()
        
        return createLoginVC
    }
}
