
import XCTest
import Nimble
import Corduroy
@testable import CorduroyTests

// Tests for the Navigator's various `goBack()` methods.
class NavigatorGoBackTests: XCTestCase {
    // Test that the navigator's `goBack()` method pops the top-most coordinator
    func testGoBackStack() {
        let navigator = Navigator()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        
        let firstVC = TestViewController().setup()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        waitUntilNextFrame()
        
        let secondVC = TestViewController().setup()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
            .configureCoordinator { secondCoordinator = $0 }
        waitUntilNextFrame()
        
        let thirdVC = TestViewController().setup()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
            .configureCoordinator { thirdCoordinator = $0 }
        waitUntilNextFrame()

        navigator.goBack()
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(2))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))
        expect(navigator.coordinators[safe: 1]).toEventually(be(secondCoordinator))

        expect(thirdCoordinator.didDismissCallCount).toEventually(equal(1))
    }

    // Test that the navigator's `goBack(to:)` method pops the correct coordinators on its way back to the specified coordinator
    func testGoBackToStack() {
        let navigator = Navigator()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        
        let firstVC = TestViewController().setup()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        waitUntilNextFrame()
        
        let secondVC = TestViewController().setup()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
            .configureCoordinator { secondCoordinator = $0 }
        waitUntilNextFrame()
        
        let thirdVC = TestViewController().setup()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
            .configureCoordinator { thirdCoordinator = $0 }
        waitUntilNextFrame()
        
        let fourthVC = TestViewController().setup()
        var fourthCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (fourthVC, ""))
            .configureCoordinator { fourthCoordinator = $0 }
        waitUntilNextFrame()

        navigator.goBack(to: firstCoordinator)
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(1))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))

        expect(secondCoordinator.didDismissCallCount).toEventually(equal(1))
        expect(thirdCoordinator.didDismissCallCount).toEventually(equal(1))
        expect(fourthCoordinator.didDismissCallCount).toEventually(equal(1))
    }

    // Test that the navigator's `goBack(toLast:)` method pops the right number of coordinators on its way back to the last
    // coordinator of the specified type and that it always pops at least one coordinator (in case the top one is of the
    // specified type).
    func testGoBackToLastStack() {
        let navigator = Navigator()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        
        // set up stack
        let firstVC = TestViewController().setup()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        waitUntilNextFrame()
        
        let secondVC = TestViewController().setup()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
            .configureCoordinator { secondCoordinator = $0 }
        waitUntilNextFrame()
        
        let thirdVC = TestViewController().setup()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
            .configureCoordinator { thirdCoordinator = $0 }
        waitUntilNextFrame()
        
        let fourthVC = TestViewController().setup()
        var fourthCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (fourthVC, ""))
            .configureCoordinator { fourthCoordinator = $0 }
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(4))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))
        expect(navigator.coordinators[safe: 1]).toEventually(be(secondCoordinator))
        expect(navigator.coordinators[safe: 2]).toEventually(be(thirdCoordinator))
        expect(navigator.coordinators[safe: 3]).toEventually(be(fourthCoordinator))

        // pop
        navigator.goBack(toLast: TestCoordinator.self)
        
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(2))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))
        expect(navigator.coordinators[safe: 1]).toEventually(be(secondCoordinator))

        expect(thirdCoordinator.didDismissCallCount).toEventually(equal(1))
        expect(fourthCoordinator.didDismissCallCount).toEventually(equal(1))

        // pop
        navigator.goBack(toLast: TestCoordinator.self)
        
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(1))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))

        expect(secondCoordinator.didDismissCallCount).toEventually(equal(1))
    }

    // Test that the navigation controller view controller stack and navigation item stack remain aligned when using the
    // navigator's `goBack(toLast:)` and `goBack(to:)` methods.
    func testGoBackNavControllerStack() {
        let navigator = Navigator()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        
        // start with a view controller in a nav controller
        let firstVC = TestEmbeddedViewController().setup()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let navController = firstVC.navigationController
        expect(navController).toNot(beNil())
        waitUntilNextFrame()
        XCTAssert(navigator.currentViewController === firstVC)
        
        // add a pushed coordinator whose view expects to be in a nav controller
        let secondVC = TestEmbeddedViewController().setup()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: .noAnimation)
            .configureCoordinator { secondCoordinator = $0 }
        waitUntilNextFrame()
        XCTAssert(navigator.currentViewController === secondVC)
        
        // add a pushed coordinator
        let thirdVC = TestViewController().setup()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        waitUntilNextFrame()
        XCTAssert(navigator.currentViewController === thirdVC)
        
        let fourthVC = TestViewController().setup()
        var fourthCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }
        waitUntilNextFrame()
        XCTAssert(navigator.currentViewController === fourthVC)

        expect(navigator.coordinators).toEventually(haveCount(4))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))
        expect(navigator.coordinators[safe: 1]).toEventually(be(secondCoordinator))
        expect(navigator.coordinators[safe: 2]).toEventually(be(thirdCoordinator))
        expect(navigator.coordinators[safe: 3]).toEventually(be(fourthCoordinator))

        expect(navController?.viewControllers).toEventually(haveCount(4))
        expect(navController?.viewControllers[safe: 0]).toEventually(be(firstVC))
        expect(navController?.viewControllers[safe: 1]).toEventually(be(secondVC))
        expect(navController?.viewControllers[safe: 2]).toEventually(be(thirdVC))
        expect(navController?.viewControllers[safe: 3]).toEventually(be(fourthVC))

        // pop to the last 'test coordinator' (should pop two coordinators)
        navigator.goBack(toLast: TestCoordinator.self, parameters: .noAnimation)
        
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(2))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))
        expect(navigator.coordinators[safe: 1]).toEventually(be(secondCoordinator))

        expect(navController?.viewControllers).toEventually(haveCount(2))
        expect(navController?.viewControllers[safe: 0]).toEventually(be(firstVC))
        expect(navController?.viewControllers[safe: 1]).toEventually(be(secondVC))

        // pop back to the first coordinator (should pop one coordinator)
        navigator.goBack(to: firstCoordinator, parameters: .noAnimation)
        
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(1))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))

        expect(secondCoordinator.didDismissCallCount).toEventually(equal(1))
    }

    // Test that the navigation controller view controller stack and navigation item stack remain aligned when the nav
    // controller's `popViewController(_:animated:)` method is called (either explicitly or via its back button)
    func testGoBackStartedFromNavControllerStack() {
        let navigator = Navigator()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        XCTAssert(navigator.currentViewController == nil)
        
        // start with a view controller in a nav controller
        let firstVC = TestEmbeddedViewController().setup()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let navController = firstVC.navigationController
        expect(navController).toNot(beNil())
        XCTAssert(navigator.currentViewController === firstVC)
        XCTAssert(navController?.viewControllers[safe: 0] === firstVC)
        waitUntilNextFrame()
        
        // add a pushed coordinator whose view expects to be in a nav controller
        let secondVC = TestEmbeddedViewController().setup()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: .noAnimation)
            .configureCoordinator { secondCoordinator = $0 }
        XCTAssert(navigator.currentViewController === secondVC)
        XCTAssert(navController?.viewControllers[safe: 1] === secondVC)
        waitUntilNextFrame()
        
        // add a pushed coordinator
        let thirdVC = TestViewController().setup()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        XCTAssert(navigator.currentViewController === thirdVC)
        XCTAssert(navController?.viewControllers[safe: 2] === thirdVC)
        waitUntilNextFrame()
        
        // add a pushed coordinator
        let fourthVC = TestViewController().setup()
        var fourthCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }
        XCTAssert(navigator.currentViewController === fourthVC)
        XCTAssert(navController?.viewControllers[safe: 3] === fourthVC)
        waitUntilNextFrame()
        
        return

        expect(navigator.coordinators).toEventually(haveCount(4))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))
        expect(navigator.coordinators[safe: 1]).toEventually(be(secondCoordinator))
        expect(navigator.coordinators[safe: 2]).toEventually(be(thirdCoordinator))
        expect(navigator.coordinators[safe: 3]).toEventually(be(fourthCoordinator))

        expect(navController?.viewControllers).toEventually(haveCount(4))
        expect(navController?.viewControllers[safe: 0]).toEventually(be(firstVC))
        expect(navController?.viewControllers[safe: 1]).toEventually(be(secondVC))
        expect(navController?.viewControllers[safe: 2]).toEventually(be(thirdVC))
        expect(navController?.viewControllers[safe: 3]).toEventually(be(fourthVC))

        // pop
        navController?.popViewController(animated: false)
        
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(3))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))
        expect(navigator.coordinators[safe: 1]).toEventually(be(secondCoordinator))

        expect(navController?.viewControllers).toEventually(haveCount(3))
        expect(navController?.viewControllers[safe: 0]).toEventually(be(firstVC))
        expect(navController?.viewControllers[safe: 1]).toEventually(be(secondVC))
        expect(navController?.viewControllers[safe: 2]).toEventually(be(thirdVC))
        
        expect(fourthCoordinator.didDismissCallCount).toEventually(equal(1))
        expect(thirdCoordinator.didDismissCallCount).toEventually(equal(0))
        expect(secondCoordinator.didDismissCallCount).toEventually(equal(0))
        expect(firstCoordinator.didDismissCallCount).toEventually(equal(0))

        // pop
        navController?.popToRootViewController(animated: false)
        
        waitUntilNextFrame()

        expect(navigator.coordinators).toEventually(haveCount(1))
        expect(navigator.coordinators[safe: 0]).toEventually(be(firstCoordinator))

        expect(navController?.viewControllers).toEventually(haveCount(1))
        expect(navController?.viewControllers[safe: 0]).toEventually(be(firstVC))

        expect(fourthCoordinator.didDismissCallCount).toEventually(equal(1))
        expect(thirdCoordinator.didDismissCallCount).toEventually(equal(1))
        expect(secondCoordinator.didDismissCallCount).toEventually(equal(1))
        expect(firstCoordinator.didDismissCallCount).toEventually(equal(0))
    }
}
