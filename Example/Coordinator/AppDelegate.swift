
import UIKit
import Coordinator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static var navigator: Navigator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let landingCoordinator = LandingCoordinator()
        AppDelegate.navigator = Navigator(onWindow: window!, firstCoordinator: landingCoordinator)
        
        return true
    }
}

