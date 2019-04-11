
import UIKit
import Corduroy

/*
 The home screen is a little more complicated (or, at least, imagine it is - tons of table view cells, complex network
 requests, etc.), so we create a coordinator object to keep the view controller a little simpler. This way,
 the actual `HomeViewController` can just be a controller of its view.
 */
final class HomeCoordinator: Coordinator, TabBarEmbeddable {
    var navigator: Navigator!
    
    func start(context: NavigationContext, embeddingFirstViewControllerWith embed: (UIViewController) -> Void) {
        let homeViewController = HomeViewController()
        homeViewController.coordinator = self
        embed(homeViewController)
    }
    
    func buttonPressed() {
        
    }
}
