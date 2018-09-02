
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
    
    /**
     Test that the navigator's `go(to:)` method produces the expected stack it's a series of coordinators each modally
     presented, mixing up the coordinator and view controller types.
     
     This is the expected coordinator/view controller stack:
     _________________________________________________________________________________
     | Coordinator    -(modal)-> | Coordinator     -(modal)-> | Coordinator(String)  |
     |---------------------------|----------------------------|----------------------|
     | VC             -(modal)-> | (Nav) _ _ _ _   -(modal)-> | TestVC               |
     |                           | EmbeddedVC   \             |                      |
     ---------------------------------------------------------------------------------
     */
    func testModallyPresentedStack() {
        let firstVC = TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        
        let secondVC = TestEmbeddedViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC, parameters: .noAnimation)
            .configureCoordinator { secondCoordinator = $0 }
        
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        
        // check the navigator coordinator stack
        expect(self.navigator.coordinators).to(haveCount(3))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        
        // check lifecycle call counts
        expect(firstCoordinator.createCallCount).to(equal(1))
        expect(secondCoordinator.createCallCount).to(equal(1))
        expect(thirdCoordinator.createCallCount).to(equal(1))
        expect(firstCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(secondCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(thirdCoordinator.presentFirstVCCallCount).to(equal(1))
        
        // check coordinator and view controller relationships
        expect(firstVC.coordinator).to(be(firstCoordinator))
        expect(secondVC.coordinator).to(be(secondCoordinator))
        expect(thirdVC.coordinator).to(be(thirdCoordinator))
        
        // check view controller relationships to one another
        expect(firstVC).to(be(self.window.rootViewController))
        expect(firstVC.presentedViewController).toEventually(be(secondVC.navigationController))
        expect(secondVC.presentingViewController).toEventually(be(firstVC))
        expect(secondVC.presentedViewController).toEventually(be(thirdVC)) //eventually because view hierarchies need to settle
        expect(thirdVC.presentingViewController).toEventually(be(secondVC.navigationController))
    }
    
    /**
     Test that the navigator's `go(to:)` method produces the expected stack when the first coordinator manages a nav
     controller, with the next couple being pushed onto the nav controller, with the last one modally presented.
     
     This is the expected coordinator/view controller stack:
     ____________________________________________________________________________________________________
     | Coordinator    -(push)-> | Coordinator  -(push)-> | Coordinator(String) -(modal)-> | Coordinator |
     |--------------------------|------------------------|--------------------------------|-------------|
     | (Nav) _ _ _ _ _ _ _ _ _ _|_ _ _ _ _ _ _ _ _ _ _ _ |_ _ _ _ _ _ _ _ _    -(modal)-> | VC          |
     | EmbeddedVC     -(push)-> | EmbeddedVC   -(push)-> | VC              \              |             |
     ----------------------------------------------------------------------------------------------------
     */
    func testNavPushThenModallyPresentedStack() {
        let firstVC = TestEmbeddedViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let navController = firstVC.navigationController
        expect(firstCoordinator.didBecomeActiveCallCount).to(equal(1))
        expect(firstCoordinator.didBecomeInactiveCallCount).to(equal(0))
        
        let secondVC = TestEmbeddedViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: .noAnimation)
            .configureCoordinator { secondCoordinator = $0 }
        expect(secondCoordinator.didBecomeActiveCallCount).to(equal(1))
        expect(secondCoordinator.didBecomeInactiveCallCount).to(equal(0))
        expect(firstCoordinator.didBecomeInactiveCallCount).to(equal(1))
        
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        expect(thirdCoordinator.didBecomeActiveCallCount).to(equal(1))
        expect(thirdCoordinator.didBecomeInactiveCallCount).to(equal(0))
        expect(secondCoordinator.didBecomeInactiveCallCount).to(equal(1))
        
        let fourthVC = TestViewController()
        var fourthCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: fourthVC, parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }
        expect(fourthCoordinator.didBecomeActiveCallCount).to(equal(1))
        expect(fourthCoordinator.didBecomeInactiveCallCount).to(equal(0))
        expect(thirdCoordinator.didBecomeInactiveCallCount).to(equal(1))

        // check the navigator coordinator stack
        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        expect(self.navigator.coordinators[3]).to(be(fourthCoordinator))
        
        // check lifecycle call counts
        expect(firstCoordinator.createCallCount).to(equal(1))
        expect(secondCoordinator.createCallCount).to(equal(1))
        expect(thirdCoordinator.createCallCount).to(equal(1))
        expect(fourthCoordinator.createCallCount).to(equal(1))
        expect(firstCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(secondCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(thirdCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(fourthCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(firstCoordinator.didDismissCallCount).to(equal(0))
        expect(secondCoordinator.didDismissCallCount).to(equal(0))
        expect(thirdCoordinator.didDismissCallCount).to(equal(0))
        expect(fourthCoordinator.didDismissCallCount).to(equal(0))
        
        // check coordinator and view controller relationships
        expect(firstVC.coordinator).to(be(firstCoordinator))
        expect(secondVC.coordinator).to(be(secondCoordinator))
        expect(thirdVC.coordinator).to(be(thirdCoordinator))
        expect(fourthVC.coordinator).to(be(fourthCoordinator))

        // check view controller relationships to one another
        expect(navController).toNot(beNil())
        expect(navController?.viewControllers).to(haveCount(3))
        expect(self.window.rootViewController).to(be(navController))
        expect(firstVC.navigationController).to(be(navController))
        expect(secondVC.navigationController).to(be(navController))
        expect(thirdVC.navigationController).to(be(navController))
        expect(fourthVC.presentingViewController).to(be(navController))
    }
    
    /**
     Test that the navigator's `go(to:)` flow coordinator method produces the expected stack when presenting it modally
     
     This is the expected coordinator/view controller stack:
     ___________________________________________________________________________________________________________________________
     | Coordinator   -(modal)-> | FlowCoordinator->Void           -(push)-> | Coordinator(String)  -(modal)-> | Coordinator    |
     |--------------------------|-------------------------|-----------------|---------------------------------|----------------|
     | VC            -(modal)-> | (Nav) _ _ _ _ _ _ _ _ _ |_ _ _ _ _ _ _ _ _|_ _ _ _ _ _ _ _ _ _   -(modal)-> | (Nav) _ _ _ _  |
     |                          | EmbeddedVC    -(push)-> | VC    -(push)-> | EmbeddedVC        \             | EmbeddedVC   \ |
     |--------------------------------------------------------------------------------------------------------------------------
    */
    func testFlowModallyPresentedStack() {
        let firstVC = TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        
        let secondVC = TestEmbeddedViewController()
        var secondCoordinator: TestFlowCoordinatorVoidCompletionModel!
        navigator.go(to: TestFlowCoordinatorVoidCompletionModel.self, by: .modallyPresenting, with: secondVC, parameters: .noAnimation, flowCompletion: { _, _ in })
            .configureCoordinator { secondCoordinator = $0 }
        let firstNavController = secondVC.navigationController
        
        let thirdVC = TestViewController()
        thirdVC.coordinator = secondCoordinator
        secondCoordinator.present(thirdVC, by: .pushing, parameters: .noAnimation)
        
        let fourthVC = TestEmbeddedViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        
        let fifthVC = TestEmbeddedViewController()
        var fourthCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: fifthVC, parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }
        let secondNavController = fifthVC.navigationController

        // check the navigator coordinator stack
        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        expect(self.navigator.coordinators[3]).to(be(fourthCoordinator))

        // check lifecycle call counts
        expect(firstCoordinator.createCallCount).to(equal(1))
        expect(secondCoordinator.createCallCount).to(equal(1))
        expect(thirdCoordinator.createCallCount).to(equal(1))
        expect(fourthCoordinator.createCallCount).to(equal(1))
        expect(firstCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(secondCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(thirdCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(fourthCoordinator.presentFirstVCCallCount).to(equal(1))
        
        // check coordinator and view controller relationships
        expect(firstVC.coordinator).to(be(firstCoordinator))
        expect(secondVC.coordinator).to(be(secondCoordinator))
        expect(thirdVC.coordinator).to(be(secondCoordinator))
        expect(fourthVC.coordinator).to(be(thirdCoordinator))
        expect(fifthVC.coordinator).to(be(fourthCoordinator))
        
        // check view controller relationships to one another
        expect(firstNavController).toNot(beNil())
        expect(firstNavController?.viewControllers).to(haveCount(3))
        expect(secondVC.navigationController).to(be(firstNavController))
        expect(thirdVC.navigationController).to(be(firstNavController))
        expect(fourthVC.navigationController).to(be(firstNavController))
        
        expect(secondNavController).toNot(beNil())
        expect(secondNavController).toNot(be(firstNavController))
        expect(secondNavController?.viewControllers).to(haveCount(1))
        expect(fifthVC.navigationController).to(be(secondNavController))

        expect(firstVC).to(be(self.window.rootViewController))
        expect(firstVC.navigationController).to(beNil())
        expect(firstVC.presentedViewController).to(be(firstNavController))
        expect(firstNavController?.presentingViewController).to(be(firstVC))
    }

    func testPassingPreconditionStack() {
        let firstVC = TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = TestViewController()
        var secondCoordinator: TestPassingPreconditionRequiringCoordinator?
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup?
        
        self.navigator.go(to: TestPassingPreconditionRequiringCoordinator.self, by: .modallyPresenting, with: secondVC, parameters: .noAnimation)
            .configureCoordinator { secondCoordinator = $0 }
            .onPreconditionFailed( { _ in XCTFail() })
        
        // evaluation is done with escaping closures (i.e. will finish evaluation after the current scope has returned),
        // so we need to push the next coordinator after a short delay so the second one's 'present first VC' is called
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""), parameters: .noAnimation)
                .configureCoordinator { thirdCoordinator = $0 }
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
