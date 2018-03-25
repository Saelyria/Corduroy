import Foundation
import Corduroy

final class WelcomeCoordinator: Coordinator {
    var navigator: Navigator!
    
    func presentViewController(context: NavigationContext) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as! WelcomeViewController
        welcomeViewController.coordinator = self
        let navController = CoordinatedNavigationController(rootViewController: welcomeViewController, navigator: self.navigator)
        
        self.present(navController, asDescribedBy: context)
    }
    
    func welcomeViewControllerDidPressSignup(_ welcomeVC: WelcomeViewController) {
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
    
    func welcomeViewControllerDidPressLater(_ welcomeVC: WelcomeViewController) {
        self.navigator.go(to: HomeCoordinator.self, by: .pushing)
    }
}
