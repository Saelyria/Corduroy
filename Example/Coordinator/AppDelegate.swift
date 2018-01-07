
import UIKit
import Coordinator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigator: Navigator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // the only things we really need to do to get started are create a navigator (an object that will do all
        /// navigation for the app), create the first coordinator, then tell the navigator to start with it. In this
        // example, the landing view controller was pretty simple, so we made it self-coordinating - see the comments
        // in `LandingViewController` for more info on that.
        self.navigator = Navigator()
        let landingCoordinator = LandingViewController.create(with: (), navigator: self.navigator)
        navigator.start(onWindow: self.window!, firstCoordinator: landingCoordinator)
        
        return true
    }
}

