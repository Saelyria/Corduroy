import UIKit
import Corduroy

typealias SettingsCoordinator = SettingsViewController

final class SettingsViewController: UIViewController, TabCoordinator, UIStoryboardInitable, NavigationControllerEmbedded {
    static let storyboardName: String = "Main"
    
    var tabBarCoordinator: TabBarCoordinator!
    var navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
