
import UIKit
import Corduroy

/*
 Here's a demo of a self-coordinating view controller. This can be used anywhere where your view controllers are pretty
 light to reduce bloat. Starting off a view controller as self-coordinating is good to get it off the ground and reduce
 boilerplate - plus, if this view controller were to become more complicated over the course of development, it wouldn't
 be hard to decide later to split it into a coordinator and view controller pair to avoid the 'Massive View Controller'
 problem. This choice of whether to split up a view controller and coordinator allows us to address 'Massive View
 Controller' on a case-per-case basis instead of introducing sweeping, complicated architecture like VIPER that, while
 simplifying complicated views, complicates simple views.
 
 Another little tidbit - while obviously not required, here I've added a typealias of WelcomeViewController to
 WelcomeCoordinator. This hides implementation details for the 'welcome' page (i.e. people that want to navigate to
 'welcome' still think to navigate to a coordinator; don't need to know that it's in fact a view controller that's self-
 coordinating). You also wouldn't need to update any code outside of the account VC / coordinator if you did decide to
 split up WelcomeViewController.
 */
typealias WelcomeCoordinator = WelcomeViewController

final class WelcomeViewController: UIViewController, Coordinator {
    var navigator: Navigator!
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var signupButton: UIButton!
    
    // Normally, we wouldn't need to implement this `Coordinator` method - a default value that creates the view
    // controller and sets its `navigator` is provided. However, because we want to instantiate our view controller from
    // a storyboard, we need to implement it.
    static func create(with: (), navigator: Navigator) -> WelcomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        welcomeViewController.navigator = navigator
        
        return welcomeViewController
    }
    
    @IBAction func signupPressed() {
        // When the 'Sign Up' button is pressed, kick off the signup flow coordinator. Flow coordinators are special
        // coordinators that are meant to perform a side task, like signing up. When navigating to them, you need to
        // provide a completion block, where it'll pass in either an error or an object of its `FlowCompletionContext`
        // associated type. The `SignupFlowCoordinator`'s completion context is a `SignupInfo` object, which we can
        // use without needing to cast or anything.
        self.navigator.go(to: SignupFlowCoordinator.self, by: .pushing, flowCompletion: { (error, signupInfo) in
            guard error == nil else { return }
            
            // when signup finishes, we want to continue to our home page.
            self.navigator.go(to: HomeCoordinator.self, by: .pushing)
        })
    }
    
    @IBAction func laterPressed() {
        self.navigator.go(to: HomeCoordinator.self, by: .pushing)
    }
}

