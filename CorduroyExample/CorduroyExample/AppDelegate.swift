
import UIKit
import Corduroy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigator: Navigator!
    
    // ugly static vars for the sake of the demo
    static var isLoggedIn: Bool = false
    static var hasSignedUp: Bool {
        return UserDefaults.standard.string(forKey: "username") != nil
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // The only things we really need to do to get started are create a navigator (an object that will do all
        /// navigation for the app) then tell the navigator to start with a given coordinator type.
        self.navigator = Navigator()
        if AppDelegate.hasSignedUp {
            navigator.start(onWindow: self.window!, firstCoordinator: HomeCoordinator.self)
        } else {
            navigator.start(onWindow: self.window!, firstCoordinator: WelcomeCoordinator.self)
        }
        
        return true
    }
}
