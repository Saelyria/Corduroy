import XCTest
import Nimble
import Corduroy

final class TestTabBarEmbeddable1: BaseTestCoordinator, Coordinator, TabBarEmbeddable {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator?
    let vc = TestEmbeddedViewController()
    
    func start(context: NavigationContext, embeddingFirstViewControllerWith embed: (UIViewController) -> Void) {
        self.vc.coordinator = self
        embed(self.vc)
    }
}

final class TestTabBarEmbeddable2: BaseTestCoordinator, Coordinator, TabBarEmbeddable {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator?
    let vc = TestViewController()
    
    func start(context: NavigationContext, embeddingFirstViewControllerWith embed: (UIViewController) -> Void) {
        self.vc.coordinator = self
        embed(self.vc)
    }
}

final class TestTabBarEmbeddable3: BaseTestCoordinator, Coordinator, TabBarEmbeddable {
    var navigator: Navigator!
    var tabBarCoordinator: TabBarCoordinator?
    let vc = TestEmbeddedViewController()
    
    func start(context: NavigationContext, embeddingFirstViewControllerWith embed: (UIViewController) -> Void) {
        self.vc.coordinator = self
        embed(self.vc)
    }
}
