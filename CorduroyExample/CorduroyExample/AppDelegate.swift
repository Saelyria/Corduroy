
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // The only things we really need to do to get started are create a navigator (an object that will do all
        /// navigation for the app) then tell the navigator to start with a given coordinator type.
        self.navigator = Navigator()
        navigator.start(onWindow: self.window!, firstCoordinator: TabBarCoordinator.self, with: [
            HomeCoordinator.self,
            ProductsCoordinator.self,
            SettingsCoordinator.self
        ])
        
//        if !AppDelegate.hasSignedUp {
            self.navigator.go(to: WelcomeCoordinator.self, by: .modallyPresenting, parameters: [.shouldAnimateTransition(false)])
//        }
        
        return true
    }
}
