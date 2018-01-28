
import UIKit
import Corduroy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigator: Navigator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // the only things we really need to do to get started are create a navigator (an object that will do all
        /// navigation for the app) then tell the navigator to start with a given coordinator type. In this example,
        // the landing view controller was pretty simple, so we made it self-coordinating - see the comments in
        // `LandingViewController` for more info on that.
        self.navigator = Navigator()
        navigator.start(onWindow: self.window!, firstCoordinator: LandingViewController.self, with: ())
        
        return true
    }
}
