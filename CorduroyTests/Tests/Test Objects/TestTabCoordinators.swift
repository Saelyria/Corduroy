import XCTest
import Nimble
import Corduroy

final class TestTabCoordinator1: BaseTestCoordinator, TabCoordinator {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator!
    
    func createViewController() -> UIViewController {
        return TestEmbeddedViewController()
    }
}

final class TestTabCoordinator2: BaseTestCoordinator, TabCoordinator {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator!
    
    func createViewController() -> UIViewController {
        return TestEmbeddedViewController()
    }
}

final class TestTabCoordinator3: BaseTestCoordinator, TabCoordinator {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator!
    
    func createViewController() -> UIViewController {
        return TestEmbeddedViewController()
    }
}
