
import XCTest
import Nimble
import Corduroy
@testable import CorduroyTests

// Tests for the Navigator's various `goBack()` methods.
class NavigatorGoBackTests: XCTestCase {
    var navigator: Navigator!
    var window: UIWindow!

    override func setUp() {
        super.setUp()
        self.navigator = Navigator()
        self.window = UIApplication.shared.delegate!.window!
    }

    override func tearDown() {
        super.tearDown()
        self.navigator = nil
    }

    // Test that the navigator's `goBack()` method pops the top-most coordinator
    func testGoBackStack() {
        let firstVC = TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = TestViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
            .configureCoordinator { secondCoordinator = $0 }
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
            .configureCoordinator { thirdCoordinator = $0 }

        navigator.goBack()

        expect(self.navigator.coordinators).to(haveCount(2))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))

        expect(thirdCoordinator.onDismissalCallCount).to(equal(1))
    }

    // Test that the navigator's `goBack(to:)` method pops the correct coordinators on its way back to the specified coordinator
    func testGoBackToStack() {
        let firstVC = TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = TestViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
            .configureCoordinator { secondCoordinator = $0 }
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
            .configureCoordinator { thirdCoordinator = $0 }
        let fourthVC = TestViewController()
        var fourthCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (fourthVC, ""))
            .configureCoordinator { fourthCoordinator = $0 }

        navigator.goBack(to: firstCoordinator)

        expect(self.navigator.coordinators).to(haveCount(1))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))

        expect(secondCoordinator.onDismissalCallCount).to(equal(1))
        expect(thirdCoordinator.onDismissalCallCount).to(equal(1))
        expect(fourthCoordinator.onDismissalCallCount).to(equal(1))
    }

    // Test that the navigator's `goBack(toLast:)` method pops the right number of coordinators on its way back to the last
    // coordinator of the specified type and that it always pops at least one coordinator (in case the top one is of the
    // specified type).
    func testGoBackToLastStack() {
        // set up stack
        let firstVC = TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        
        let secondVC = TestViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
            .configureCoordinator { secondCoordinator = $0 }
        
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
            .configureCoordinator { thirdCoordinator = $0 }
        
        let fourthVC = TestViewController()
        var fourthCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (fourthVC, ""))
            .configureCoordinator { fourthCoordinator = $0 }

        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        expect(self.navigator.coordinators[3]).to(be(fourthCoordinator))

        // pop
        navigator.goBack(toLast: TestCoordinator.self)

        expect(self.navigator.coordinators).to(haveCount(2))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))

        expect(thirdCoordinator.onDismissalCallCount).to(equal(1))
        expect(fourthCoordinator.onDismissalCallCount).to(equal(1))

        // pop
        navigator.goBack(toLast: TestCoordinator.self)

        expect(self.navigator.coordinators).to(haveCount(1))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))

        expect(secondCoordinator.onDismissalCallCount).to(equal(1))
    }

    // Test that the navigation controller view controller stack and navigation item stack remain aligned when using the
    // navigator's `goBack(toLast:)` and `goBack(to:)` methods.
    func testGoBackNavControllerStack() {
        // start with a view controller in a nav controller
        let firstVC = TestEmbeddedViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let navController = firstVC.navigationController
        expect(navController).toNot(beNil())
        
        // add a pushed coordinator whose view expects to be in a nav controller
        let secondVC = TestEmbeddedViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: .noAnimation)
            .configureCoordinator { secondCoordinator = $0 }
        
        // add a pushed coordinator
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        
        let fourthVC = TestViewController()
        var fourthCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }

        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        expect(self.navigator.coordinators[3]).to(be(fourthCoordinator))

        expect(navController?.viewControllers).to(haveCount(4))
        expect(navController?.viewControllers[0]).to(be(firstVC))
        expect(navController?.viewControllers[1]).to(be(secondVC))
        expect(navController?.viewControllers[2]).to(be(thirdVC))
        expect(navController?.viewControllers[3]).to(be(fourthVC))

        // pop to the last 'test coordinator' (should pop two coordinators)
        navigator.goBack(toLast: TestCoordinator.self, parameters: .noAnimation)

        expect(self.navigator.coordinators).to(haveCount(2))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))

        expect(navController?.viewControllers).to(haveCount(2))
        expect(navController?.viewControllers[0]).to(be(firstVC))
        expect(navController?.viewControllers[1]).to(be(secondVC))

        // pop back to the first coordinator (should pop one coordinator)
        navigator.goBack(to: firstCoordinator, parameters: .noAnimation)

        expect(self.navigator.coordinators).to(haveCount(1))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))

        expect(secondCoordinator.onDismissalCallCount).to(equal(1))
    }

    // Test that the navigation controller view controller stack and navigation item stack remain aligned when the nav
    // controller's `popViewController(_:animated:)` method is called (either explicitly or via its back button)
    func testGoBackStartedFromNavControllerStack() {
        // start with a view controller in a nav controller
        let firstVC = TestEmbeddedViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let navController = firstVC.navigationController
        expect(navController).toNot(beNil())
        
        // add a pushed coordinator whose view expects to be in a nav controller
        let secondVC = TestEmbeddedViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: .noAnimation)
            .configureCoordinator { secondCoordinator = $0 }
        
        // add a pushed coordinator
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        
        // add a pushed coordinator
        let fourthVC = TestViewController()
        var fourthCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }

        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        expect(self.navigator.coordinators[3]).to(be(fourthCoordinator))

        expect(navController?.viewControllers).to(haveCount(4))
        expect(navController?.viewControllers[0]).to(be(firstVC))
        expect(navController?.viewControllers[1]).to(be(secondVC))
        expect(navController?.viewControllers[2]).to(be(thirdVC))
        expect(navController?.viewControllers[3]).to(be(fourthVC))

        // pop
        navController?.popViewController(animated: false)

        expect(self.navigator.coordinators).to(haveCount(3))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))

        expect(navController?.viewControllers).to(haveCount(3))
        expect(navController?.viewControllers[0]).to(be(firstVC))
        expect(navController?.viewControllers[1]).to(be(secondVC))
        expect(navController?.viewControllers[2]).to(be(thirdVC))
        
        expect(fourthCoordinator.onDismissalCallCount).to(equal(1))
        expect(thirdCoordinator.onDismissalCallCount).to(equal(0))
        expect(secondCoordinator.onDismissalCallCount).to(equal(0))
        expect(firstCoordinator.onDismissalCallCount).to(equal(0))

        // pop
        navController?.popToRootViewController(animated: false)

        expect(self.navigator.coordinators).to(haveCount(1))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))

        expect(navController?.viewControllers).to(haveCount(1))
        expect(navController?.viewControllers[0]).to(be(firstVC))

        expect(fourthCoordinator.onDismissalCallCount).to(equal(1))
        expect(thirdCoordinator.onDismissalCallCount).to(equal(1))
        expect(secondCoordinator.onDismissalCallCount).to(equal(1))
        expect(firstCoordinator.onDismissalCallCount).to(equal(0))
    }
}
