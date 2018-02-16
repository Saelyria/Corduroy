
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
        
    }
    
    // Test that the navigator's `go(to:)` flow coordinator method produces the expected stack when presenting it modally
    func testGoToFlowCoordinatorStack() {
        let noAnimationParams = NavigationParameters(animateTransition: false)
        let firstVC = TestCoordinator.TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = TestFlowCoordinatorNothingCompletionModel.TestViewController()
        let secondCoordinator = navigator.go(to: TestFlowCoordinatorNothingCompletionModel.self, by: .modallyPresenting, with: secondVC,
            parameters: noAnimationParams, flowCompletion: { _, _ in })
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
    
    // Test that the navigator's `go(to:)` flow coordinator method produces the expected navigator and navigation controller stacks
    // when the flow coordinator's navigation controller has multiple items in it
    func testGoToFlowCoordinatorNavControllerPushStack() {
        // setup the stack, making the flow coordinator have a nav controller with two VCs in its stack
        let noAnimationParams = NavigationParameters(animateTransition: false)
        let firstVC = TestCoordinator.TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = TestFlowCoordinatorNothingCompletionModel.TestViewController()
        let flowNavController = CoordinatedNavigationController(rootViewController: secondVC, navigator: navigator)
        let secondCoordinator = navigator.go(to: TestFlowCoordinatorNothingCompletionModel.self, by: .modallyPresenting, with: flowNavController,
            parameters: noAnimationParams, flowCompletion: { _, _ in })
        let thirdVC = TestFlowCoordinatorNothingCompletionModel.TestViewController()
        flowNavController.pushViewController(thirdVC, animated: false)
        let fourthVC = TestCoordinatorStringSetup.TestViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (fourthVC, ""), parameters: noAnimationParams)
        
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
        
        expect(flowNavController.viewControllers).to(haveCount(2))
        expect(flowNavController.viewControllers[0]).to(be(secondVC))
        expect(flowNavController.viewControllers[1]).to(be(thirdVC))
        expect(firstVC).to(be(self.window.rootViewController))
        expect(firstVC.presentedViewController).to(be(flowNavController))
        expect(secondVC.navigationController).to(be(flowNavController))
        expect(thirdVC.navigationController).to(be(flowNavController))
        expect(fourthVC.presentingViewController).toEventually(be(flowNavController)) //eventually because view hierarchies need to settle
    }
    
    // Test that the navigator's `go(to:)` flow coordinator method produces the expected navigator and navigation controller stacks
    // when the flow coordinator's view controllers are part of a navigation controller along with other coordinators' view controllers
    func testGoToFlowCoordinatorAllInNavController() {
        // setup the stack with all VCs in the same nav controller
        let noAnimationParams = NavigationParameters(animateTransition: false) // don't animate so we can test without waiting
        let firstVC = TestCoordinator.TestViewController()
        let navController = CoordinatedNavigationController(rootViewController: firstVC, navigator: navigator)
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: navController)
        let secondVC = TestFlowCoordinatorNothingCompletionModel.TestViewController()
        let secondCoordinator = navigator.go(to: TestFlowCoordinatorNothingCompletionModel.self, by: .pushing, with: secondVC,
            parameters: noAnimationParams, flowCompletion: { _, _ in })
        let thirdVC = TestFlowCoordinatorNothingCompletionModel.TestViewController()
        navController.pushViewController(thirdVC, animated: false)
        let fourthVC = TestCoordinatorStringSetup.TestViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (fourthVC, ""), parameters: noAnimationParams)
        
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
        
        expect(navController.viewControllers).to(haveCount(4))
        expect(navController.viewControllers[0]).to(be(firstVC))
        expect(navController.viewControllers[1]).to(be(secondVC))
        expect(navController.viewControllers[2]).to(be(thirdVC))
        expect(navController.viewControllers[3]).to(be(fourthVC))
        expect(firstVC).to(be(self.window.rootViewController))
    }
    
    func testEvaluateAndGoToPassingStack() {
        let noAnimationParams = NavigationParameters(animateTransition: false)
        let firstVC = TestCoordinator.TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = TestPassingPreconditionRequiringCoordinator.TestViewController()
        var secondCoordinator: TestPassingPreconditionRequiringCoordinator?
        let thirdVC = TestCoordinatorStringSetup.TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup?
        self.navigator.evaluatePreconditionsAndGo(to: TestPassingPreconditionRequiringCoordinator.self, by: .modallyPresenting,
        with: secondVC, parameters: noAnimationParams, evaluationCompletion: { (error, coordinator) in
            expect(coordinator).toNot(beNil())
            expect(error).to(beNil())
            secondCoordinator = coordinator
        })
        // evaluation is done with escaping closures (i.e. will finish evaluation after the current scope has returned),
        // so we need to push the next coordinator after a short delay so the second one's 'present first VC' is called
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            thirdCoordinator = self.navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""), parameters: noAnimationParams)
        }
        
        expect(self.navigator.coordinators).toEventually(haveCount(3))
        expect(self.navigator.coordinators[0]).toEventually(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).toEventually(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).toEventually(be(thirdCoordinator))
        
        expect(firstCoordinator.createCallCount).to(equal(1))
        expect(secondCoordinator?.createCallCount).toEventually(equal(1))
        expect(thirdCoordinator?.createCallCount).toEventually(equal(1))
        expect(firstCoordinator.presentFirstVCCallCount).toEventually(equal(1))
        expect(secondCoordinator?.presentFirstVCCallCount).toEventually(equal(1))
        expect(thirdCoordinator?.presentFirstVCCallCount).toEventually(equal(1))
        
        expect(firstVC).to(be(self.window.rootViewController))
        expect(firstVC.presentedViewController).toEventually(be(secondVC))
        expect(secondVC.presentingViewController).toEventually(be(firstVC))
        expect(secondVC.presentedViewController).toEventually(be(thirdVC)) //eventually because view hierarchies need to settle
        expect(thirdVC.presentingViewController).toEventually(be(secondVC))
    }
}
