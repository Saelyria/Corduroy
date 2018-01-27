
import UIKit

/*
 The tests need a UIWindow to work properly for testing UIViewController navigation (specifically their presented and
 presenting view controller variables). Since Corduroy is a framework, its `UIApplication.shared.keyWindow` is always
 nil. UIWindows also cannot have 'makeKeyAndVisible' called on them outside of an app project, meaning we need to make
 this 'CorduroyTests' project separate from the Corduroy project to have a basic app (basically just an app delegate)
 that can have a non-nil window.
 
 I'll also note here that Cocoapods became too much of a hassle with this bizarre project structure, so I just included
 Nimble in the project outside of Cocoapods.
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        return true
    }
}

