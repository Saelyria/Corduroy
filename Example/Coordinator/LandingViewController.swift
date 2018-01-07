
import UIKit
import Coordinator

/*
 This landing view controller is pretty simple and its two navigation conditions - when its 'Login' button or its
 'Start Tutorial' buttons are pressed - are both coupled tightly to the view controller, so we'll make it a
 self-coordinating view controller (by conforming to `SelfCoordinating`) to reduce bloat.
 
 If this view controller were to become more complicated over the course of development, it wouldn't be hard to decide
 later to split it into a coordinator and view controller pair to avoid the 'Massive View Controller' problem.
*/
 
final class LandingViewController: UIViewController, SelfCoordinating {
    // there's a couple caveats for implementing `SelfCoordinating` - we need to explicitly set the `ManagingCoordinator`
    // type to the view controller's type, and we need to declare the `coordinator` property (which will just be a
    // reference to `self`, but unfortunately, protocol extensions only go so far).
    typealias ManagingCoordinator = LandingViewController

    var navigator: Navigator!
    var coordinator: LandingViewController?
    
    // because we haven't defined a `SetupModel` type (we left it as `Void`), a default implementation for
    // `create(with:navigator)` is provided. We can implement it ourselves if we want to, though, like if we needed to
    // instantiate from a storyboard. The default implementation simply calls the view controller's `init()` method.
    
    // we also don't need to implement the `start(context:)` on self-coordinating view controllers if we don't plan to
    // do anything special - by default, it will perform an appropriate navigation (push, modal present, etc,) based on
    // the passed-in context. For more info, look at the `SelfCoordinating` extension under its declaration and the
    // `UIViewController+Navigator.swift` file.

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
        let signupFlowCoordinator = SignupFlowCoordinator.create(with: (), navigator: self.navigator)
        self.navigator.go(to: signupFlowCoordinator, by: .modallyPresenting) { (error, signupInfo) in
            
        }
    }
    
    @objc func startTutorialPressed(sender: UIButton) {
        
    }
}

