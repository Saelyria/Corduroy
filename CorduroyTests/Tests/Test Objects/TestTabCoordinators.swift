import XCTest
import Nimble
import Corduroy

final class TestTabCoordinator1: BaseTestCoordinator, TabCoordinator {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator!
    let vc = TestEmbeddedViewController()
    
    func createViewController() -> UIViewController {
        self.vc.coordinator = self
        return self.vc
    }
}

final class TestTabCoordinator2: BaseTestCoordinator, TabCoordinator {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator!
    let vc = TestViewController()
    
    func createViewController() -> UIViewController {
        self.vc.coordinator = self
        return self.vc
    }
}

final class TestTabCoordinator3: BaseTestCoordinator, TabCoordinator {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator!
    let vc = TestEmbeddedViewController()
    
    func createViewController() -> UIViewController {
        self.vc.coordinator = self
        return self.vc
    }
}
