
import XCTest
import Nimble
import Corduroy
@testable import CorduroyTests

// Tests for the `Navigator`'s various `go(to:)` methods.
class NavigatorGoTests: XCTestCase {
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
    
    // Test that the navigator's `go(to:)` method produces the expected stack when modally presenting
    func testGoToCoordinatorStack() {
        let noAnimationParams = NavigationParameters(animateTransition: false)
        let firstVC = TestCoordinator.TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = TestCoordinator.TestViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC, parameters: noAnimationParams)
        let thirdVC = TestCoordinatorStringSetup.TestViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""), parameters: noAnimationParams)
        
        expect(self.navigator.coordinators).to(haveCount(3))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        
        expect(firstCoordinator.createCallCount).to(equal(1))
        expect(secondCoordinator.createCallCount).to(equal(1))
        expect(thirdCoordinator.createCallCount).to(equal(1))
        expect(firstCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(secondCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(thirdCoordinator.presentFirstVCCallCount).to(equal(1))
        
        expect(firstVC).to(be(self.window.rootViewController))
        expect(firstVC.presentedViewController).to(be(secondVC))
        expect(secondVC.presentingViewController).to(be(firstVC))
        expect(secondVC.presentedViewController).toEventually(be(thirdVC)) //eventually because view hierarchies need to settle
        expect(thirdVC.presentingViewController).toEventually(be(secondVC))
    }
    
    // Test that the navigator's `go(to:)` method produces the expected stack when using a nav controller then modally presenting
    func testGoToCoordinatorNavControllerStack() {
        let noAnimationParams = NavigationParameters(animateTransition: false)
        let firstVC = UIViewController()
        let navController = CoordinatedNavigationController(rootViewController: firstVC, navigator: self.navigator)
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: navController)
        let secondVC = TestCoordinator.TestViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: noAnimationParams)
        let thirdVC = TestCoordinatorStringSetup.TestViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: noAnimationParams)
        let fourthVC = TestCoordinator.TestViewController()
        let fourthCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: fourthVC, parameters: noAnimationParams)
        
        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        expect(self.navigator.coordinators[3]).to(be(fourthCoordinator))
        
        expect(navController.viewControllers).to(haveCount(3))
        expect(self.window.rootViewController).to(be(navController))
        expect(firstVC.navigationController).to(be(navController))
        expect(secondVC.navigationController).to(be(navController))
        expect(thirdVC.navigationController).to(be(navController))
        expect(fourthVC.presentingViewController).to(be(navController))
    }
    
    func testGoToStackMultipleVCsPerCoordinator() {
        let noAnimationParams = NavigationParameters(animateTransition: false)
        let firstVC = UIViewController()
        let navController = CoordinatedNavigationController(rootViewController: firstVC, navigator: self.navigator)
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: navController)
        let secondVC = TestCoordinator.TestViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: noAnimationParams)
        let thirdVC = TestCoordinatorStringSetup.TestViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: noAnimationParams)
        let fourthVC = TestCoordinator.TestViewController()
        let fourthCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: fourthVC, parameters: noAnimationParams)
        
        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        expect(self.navigator.coordinators[3]).to(be(fourthCoordinator))
        
        expect(navController.viewControllers).to(haveCount(3))
        expect(self.window.rootViewController).to(be(navController))
        expect(firstVC.navigationController).to(be(navController))
        expect(secondVC.navigationController).to(be(navController))
        expect(thirdVC.navigationController).to(be(navController))
        expect(fourthVC.presentingViewController).to(be(navController))
    }
    
    func testGoToFlowCoordinator() {
        let noAnimationParams = NavigationParameters(animateTransition: false)
        let firstVC = TestCoordinator.TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = TestFlowCoordinatorVoidCompletionModel.TestViewController()
        let secondCoordinator = navigator.go(to: TestFlowCoordinatorVoidCompletionModel.self, by: .modallyPresenting, with: secondVC, parameters: noAnimationParams, flowCompletion: { _, _ in
            
        })
        let thirdVC = TestCoordinatorStringSetup.TestViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""), parameters: noAnimationParams)
        
        expect(self.navigator.coordinators).to(haveCount(3))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        
        expect(firstCoordinator.createCallCount).to(equal(1))
        expect(secondCoordinator.createCallCount).to(equal(1))
        expect(thirdCoordinator.createCallCount).to(equal(1))
        expect(firstCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(secondCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(thirdCoordinator.presentFirstVCCallCount).to(equal(1))
        
        expect(firstVC).to(be(self.window.rootViewController))
        expect(firstVC.presentedViewController).to(be(secondVC))
        expect(secondVC.presentingViewController).to(be(firstVC))
        expect(secondVC.presentedViewController).toEventually(be(thirdVC)) //eventually because view hierarchies need to settle
        expect(thirdVC.presentingViewController).toEventually(be(secondVC))
    }
}
