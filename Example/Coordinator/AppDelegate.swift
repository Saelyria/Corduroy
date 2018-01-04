
import UIKit
import Coordinator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let landingCoordinator = LandingCoordinator()
        CoordinatorRouter.shared.start(onWindow: self.window!, withCoordinator: landingCoordinator)

        return true
    }
}

