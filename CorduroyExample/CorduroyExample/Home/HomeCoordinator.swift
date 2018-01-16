
import UIKit
import Corduroy

// The home screen's navigation is a little more complicated, so we create a coordinator object to handle it. This way,
// the actual `HomeViewController` can just be a controller of its view.
final class HomeCoordinator: Coordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        let homeViewController = HomeViewController()
        homeViewController.coordinator = self
        self.currentViewController = homeViewController
        context.currentViewController.present(homeViewController, context: context)
    }
    
    func buttonPressed() {
        self.navigator.go(to: SomeOtherCoordinator.self)
    }
}

final class SomeOtherCoordinator: Coordinator {
    var navigator: Navigator!
    var currentViewController: UIViewController?
    
    func presentFirstViewController(context: Navigator.NavigationContext) {
        let homeViewController = SomeViewController()
        homeViewController.coordinator = self
        self.currentViewController = homeViewController
        context.currentViewController.present(homeViewController, context: context)
    }
    
    func goBack() {
        self.navigator.goBack(toLast: LandingViewController.self)
    }
}

class SomeViewController: UIViewController, CoordinatorManageable {
    var coordinator: SomeOtherCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 100))
        self.view.addSubview(button)
        button.setTitle("Go back", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        self.coordinator?.goBack()
    }
}
