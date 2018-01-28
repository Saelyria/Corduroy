
import UIKit

/*
 The tests need a UIWindow to work properly for testing UIViewController navigation (specifically their presented and
 presenting view controller variables). Since Corduroy is a framework, its `UIApplication.shared.keyWindow` is always
 nil. UIWindows also cannot have 'makeKeyAndVisible' called on them outside of an app project (RE the 'props must have a
 valid clientID' exception), meaning we need to make this 'CorduroyTests' project separate from the Corduroy project to
 have a basic app (basically just an app delegate) so that we can have a non-nil window.
 
 I'll also note here that Cocoapods became too much of a hassle with this bizarre project structure, so I just included
 Nimble in the project outside of Cocoapods. Nimble was required because it includes functionality to test 'fatalError'
 calls and it's also simply a better testing framework than XCTest.
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = UIViewController()
        return true
    }
    
    func doError() {
        fatalError("An error")
    }
}

