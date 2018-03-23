
import UIKit
import Corduroy

/*
 This welcome view controller is pretty simple and its two navigation conditions - when its 'Sign Up' button or its
 'Start Tutorial' buttons are pressed - are both coupled tightly to the view controller, so we'll make it a
 self-coordinating view controller (by conforming to `SelfCoordinating`) to reduce bloat.
 
 If this view controller were to become more complicated over the course of development, it wouldn't be hard to decide
 later to split it into a coordinator and view controller pair to avoid the 'Massive View Controller' problem.
 
 Another little tidbit - while obviously not required, here I've added a typealias of WelcomeViewController to
 WelcomeCoordinator. This hides implementation details for the 'welcome' page (i.e. people that want to navigate to
 'welcome' still think to navigate to a coordinator; don't need to know that it's in fact a view controller that's self-
 coordinating). You also wouldn't need to update any code outside of the landing VC / coordinator if you did decide to
 split up WelcomeViewController.
*/
typealias WelcomeCoordinator = WelcomeViewController

final class WelcomeViewController: UIViewController, SelfCoordinating {
    var navigator: Navigator!
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var signupButton: UIButton!
    
    // This 'create(with:navigator:)' method is a requirement of all 'Coordinators' and is how 'Navigator' objects
    // create coordinators when they are navigated to. Since our view controller is self-coordinating, it needs to be
    // implemented. However, a default implementation is provided by the `SelfCoordinating` protocol if the view
    // controller doesn't declare a `SetupModel` associated type - by default, it will instantiate it with its
    // `init(nibName:bundle:)` method and set its `navigator` property. However, because we want to instantiate our
    // view controller from a storyboard, we need to implement it.
    static func create(with: (), navigator: Navigator) -> WelcomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        welcomeViewController.navigator = navigator
        
        return welcomeViewController
    }
    
    // We also don't need to implement the `presentViewController(context:)` on self-coordinating view controllers
    // if we don't plan to do anything special - by default, it will perform an appropriate navigation (push, modal
    // present, etc.) based on the passed-in context. For more info, look at the `SelfCoordinating` extension under its
    // declaration and the `UIViewController+Navigator.swift` file.
    //
    // Here, however, we want the view controller in a nav controller, so we create that and present it from the
    // context's `currentViewController`.
    func presentViewController(context: NavigationContext) {
        let navController = CoordinatedNavigationController(rootViewController: self, navigator: self.navigator)
        self.present(navController, asDescribedBy: context)
    }
    
    @IBAction func signupPressed(sender: UIButton) {
        // When the 'Sign Up' button is pressed, kick off the signup flow coordinator. Flow coordinators are special
        // coordinators that are meant to perform a side task, like signing up. When navigating to them, you need to
        // provide a completion block, where it'll pass in either an error or an object of its `FlowCompletionContext`
        // associated type. The `SignupFlowCoordinator`'s completion context is a `SignupInfo` object, which we can
        // use without needing to cast or anything.
        self.navigator.go(to: SignupFlowCoordinator.self, by: .pushing, flowCompletion: { (error, signupInfo) in
            if let signupInfo = signupInfo {
                // save to user defaults for the sake of the demo
                UserDefaults.standard.set(signupInfo.username, forKey: "username")
                UserDefaults.standard.set(signupInfo.password, forKey: "password")
                UserDefaults.standard.set(signupInfo.securityQuestion, forKey: "security-question")
                UserDefaults.standard.set(signupInfo.securityAnswer, forKey: "security-answer")
            }

            // when signup finishes, we want to continue to our home page.
            self.navigator.go(to: HomeCoordinator.self, by: .pushing)
        })
    }
}

