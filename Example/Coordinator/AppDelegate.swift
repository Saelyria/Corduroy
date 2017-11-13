
import UIKit
import Coordinator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = UIViewController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        let appCoordinator = AppCoordinator()
        appCoordinator.start(with: EmptyContext(), from: rootViewController)
        
        return true
    }
}

