
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
        
        // expect the navigator to have three coordinators in the right order
        expect(self.navigator.coordinators).to(haveCount(3))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        
        // expect the coordinator's `create` and `present` methods to have been called only once
        expect(firstCoordinator.createCallCount).to(equal(1))
        expect(secondCoordinator.createCallCount).to(equal(1))
        expect(thirdCoordinator.createCallCount).to(equal(1))
        expect(firstCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(secondCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(thirdCoordinator.presentFirstVCCallCount).to(equal(1))
        
        // expect the view controllers to have the appropriate presentation relationships to each other
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
        expect(navController).toNot(beNil())
        
        let secondVC = TestEmbeddedViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: .noAnimation)
            .configureCoordinator { secondCoordinator = $0 }
        
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        
        let fourthVC = TestViewController()
        var fourthCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: fourthVC, parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }

        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        expect(self.navigator.coordinators[2]).to(be(thirdCoordinator))
        expect(self.navigator.coordinators[3]).to(be(fourthCoordinator))

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
        
        let thirdVC = TestViewController()
        secondCoordinator.present(thirdVC, by: .pushing, parameters: .noAnimation)
        
        let fourthVC = TestEmbeddedViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        
        let fifthVC = TestEmbeddedViewController()
        var fourthCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: fifthVC, parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }

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

        // check view controller relationships to one another
        expect(firstVC).to(be(self.window.rootViewController))
        expect(firstVC.presentedViewController).to(be(secondVC.navigationController))
        expect(secondVC.presentingViewController).to(be(firstVC))
        expect(secondVC.presentedViewController).toEventually(be(thirdVC))
        expect(thirdVC.presentingViewController).toEventually(be(secondVC.navigationController))
    }

    // Test that the navigator's `go(to:)` flow coordinator method produces the expected navigator and navigation controller stacks
    // when the flow coordinator's navigation controller has multiple items in it
    func testGoToFlowCoordinatorNavControllerPushStack() {
        // start with a view controller NOT in a nav controller
        let firstVC = TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        
        // add a modally presented flow coordinator whose views are in a nav controller
        let secondVC = TestEmbeddedViewController()
        var secondCoordinator: TestFlowCoordinatorVoidCompletionModel!
        navigator.go(to: TestFlowCoordinatorVoidCompletionModel.self, by: .modallyPresenting, with: secondVC, parameters: .noAnimation, flowCompletion: { _, _ in })
            .configureCoordinator { secondCoordinator = $0 }
        let flowNavController = secondVC.navigationController
        expect(flowNavController).toNot(beNil())
        
        // have the flow coordinator push a new view controller
        let thirdVC = TestViewController()
        flowNavController?.pushViewController(thirdVC, animated: false)
        
        // add a modally presented coordinator
        let fourthVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }

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

        expect(flowNavController?.viewControllers).to(haveCount(2))
        expect(flowNavController?.viewControllers[0]).to(be(secondVC))
        expect(flowNavController?.viewControllers[1]).to(be(thirdVC))
        expect(firstVC).to(be(self.window.rootViewController))
        expect(firstVC.presentedViewController).to(be(flowNavController))
        expect(secondVC.navigationController).to(be(flowNavController))
        expect(thirdVC.navigationController).to(be(flowNavController))
        expect(fourthVC.presentingViewController).toEventually(be(flowNavController)) //eventually because view hierarchies need to settle
    }

    // Test that the navigator's `go(to:)` flow coordinator method produces the expected navigator and navigation controller stacks
    // when the flow coordinator's view controllers are part of a navigation controller along with other coordinators' view controllers
    func testGoToFlowCoordinatorAllInNavController() {
        // start with a view controller embedded in a nav controller
        let firstVC = TestEmbeddedViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let navController = firstVC.navigationController
        expect(navController).toNot(beNil())
        
        // add a flow coordinator pushed on the same nav controller
        let secondVC = TestViewController()
        var secondCoordinator: TestFlowCoordinatorVoidCompletionModel!
        navigator.go(to: TestFlowCoordinatorVoidCompletionModel.self, by: .pushing, with: secondVC, parameters: .noAnimation, flowCompletion: { _, _ in })
            .configureCoordinator { secondCoordinator = $0 }
        
        // have the flow coordinator push a new view controller
        let thirdVC = TestViewController()
        secondCoordinator.present(thirdVC, by: .pushing, parameters: .noAnimation)
        
        // add a new coordinator pushed on the same nav controller
        let fourthVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }

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

        expect(navController?.viewControllers).to(haveCount(4))
        expect(navController?.viewControllers[0]).to(be(firstVC))
        expect(navController?.viewControllers[1]).to(be(secondVC))
        expect(navController?.viewControllers[2]).to(be(thirdVC))
        expect(navController?.viewControllers[3]).to(be(fourthVC))
        expect(navController).to(be(self.window.rootViewController))
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
