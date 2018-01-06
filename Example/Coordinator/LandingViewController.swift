
import UIKit
import Coordinator

final class LandingViewController: UIViewController, CoordinatorManageable {
    var coordinator: LandingCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = "Welcome to my cool app!\n\nPlease sign up below so we can sell your info online."
        self.view.addSubview(label)
        NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        let startLoginButton = UIButton(type: .system)
        startLoginButton.translatesAutoresizingMaskIntoConstraints = false
        startLoginButton.setTitle("Sign Up", for: .normal)
        startLoginButton.addTarget(self, action: #selector(startLoginPressed), for: .touchUpInside)
        self.view.addSubview(startLoginButton)
        NSLayoutConstraint(item: startLoginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: startLoginButton, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 40).isActive = true
    }
    
    @objc func startLoginPressed(sender: UIButton) {
        self.coordinator?.landingViewControllerDidPressLogin(self)
    }
    
    @objc func startTutorialPressed(sender: UIButton) {
        self.coordinator?.landingViewControllerDidPressTutorial(self)
    }
}

