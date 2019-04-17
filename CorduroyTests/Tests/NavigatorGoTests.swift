
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
     Test that the navigator's `go(to:)` method produces the expected stack if it's a series of coordinators each
     modally presented, mixing up the coordinator and view controller types.
     
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
        expect(firstCoordinator.viewControllers).to(haveCount(1))
        expect(firstCoordinator.viewControllers[0]).to(be(firstVC))
        expect(secondVC.coordinator).to(be(secondCoordinator))
        expect(secondCoordinator.viewControllers).to(haveCount(1))
        expect(secondCoordinator.viewControllers[0]).to(be(secondVC))
        expect(thirdVC.coordinator).to(be(thirdCoordinator))
        expect(thirdCoordinator.viewControllers).to(haveCount(1))
        expect(thirdCoordinator.viewControllers[0]).to(be(thirdVC))
        
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
//        expect(firstCoordinator.didBecomeInactiveCallCount).to(equal(1))
        
        let thirdVC = TestViewController()
        var thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: .noAnimation)
            .configureCoordinator { thirdCoordinator = $0 }
        expect(thirdCoordinator.didBecomeActiveCallCount).to(equal(1))
        expect(thirdCoordinator.didBecomeInactiveCallCount).to(equal(0))
//        expect(secondCoordinator.didBecomeInactiveCallCount).to(equal(1))
        
        let fourthVC = TestViewController()
        var fourthCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: fourthVC, parameters: .noAnimation)
            .configureCoordinator { fourthCoordinator = $0 }
        expect(fourthCoordinator.didBecomeActiveCallCount).to(equal(1))
        expect(fourthCoordinator.didBecomeInactiveCallCount).to(equal(0))
//        expect(thirdCoordinator.didBecomeInactiveCallCount).to(equal(1))

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
        expect(firstCoordinator.viewControllers).to(haveCount(1))
        expect(firstCoordinator.viewControllers[0]).to(be(firstVC))
        expect(secondVC.coordinator).to(be(secondCoordinator))
        expect(secondCoordinator.viewControllers).to(haveCount(1))
        expect(secondCoordinator.viewControllers[0]).to(be(secondVC))
        expect(thirdVC.coordinator).to(be(thirdCoordinator))
        expect(thirdCoordinator.viewControllers).to(haveCount(1))
        expect(thirdCoordinator.viewControllers[0]).to(be(thirdVC))
        expect(fourthVC.coordinator).to(be(fourthCoordinator))
        expect(fourthCoordinator.viewControllers).to(haveCount(1))
        expect(fourthCoordinator.viewControllers[0]).to(be(fourthVC))

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
     Test that the navigator's `go(to:)` flow coordinator method produces the expected stack when a coordinator pushes
     a flow coordinator that uses a navigation controller, a new coordinator is pushed that uses that same navigation
     controller for its view controller, then a new coordinator is modally presented that starts a new navigation
     controller.
     
     This is the expected coordinator/view controller stack:
     ___________________________________________________________________________________________________________________________
     | Coordinator   -(modal)-> | FlowCoordinator->Void           -(push)-> | Coordinator(String)  -(modal)-> | Coordinator    |
     |--------------------------|-------------------------|-----------------|---------------------------------|----------------|
     | VC            -(modal)-> | (Nav) _ _ _ _ _ _ _ _ _ |_ _ _ _ _ _ _ _ _|_ _ _ _ _ _ _ _ _ _   -(modal)-> | (Nav) _ _ _ _  |
     |                          | EmbeddedVC    -(push)-> | VC    -(push)-> | EmbeddedVC        \             | EmbeddedVC   \ |
     ---------------------------------------------------------------------------------------------------------------------------
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
        expect(firstCoordinator.viewControllers).to(haveCount(1))
        expect(firstCoordinator.viewControllers[0]).to(be(firstVC))
        expect(secondVC.coordinator).to(be(secondCoordinator))
        expect(thirdVC.coordinator).to(be(secondCoordinator))
        expect(secondCoordinator.viewControllers).to(haveCount(2))
        expect(secondCoordinator.viewControllers[0]).to(be(secondVC))
        expect(secondCoordinator.viewControllers[1]).to(be(thirdVC))
        expect(fourthVC.coordinator).to(be(thirdCoordinator))
        expect(thirdCoordinator.viewControllers).to(haveCount(1))
        expect(thirdCoordinator.viewControllers[0]).to(be(fourthVC))
        expect(fifthVC.coordinator).to(be(fourthCoordinator))
        expect(fourthCoordinator.viewControllers).to(haveCount(1))
        expect(fourthCoordinator.viewControllers[0]).to(be(fifthVC))
        
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
    
    /**
     Test that the navigator's `go(to:)` methods produce the expected stack when the app uses a tab bar coordinator.
     The test involves first setting up a flow coordinator stack with the first tab where the flow coordinator continues
     its navigation using the navigation controller from the base view controller. The navigator then switches tabs and
     modally presents an embedded view controller. One of the key testing points here is that a modal presentation
     'covers' the tab bar, so switching tabs at this point changes the stack only under this modally presented
     coordinator.
     
     This is the expected coordinator/view controller stack:
     _________________________ _____________________________________________________________________________________________________________ ________________________
     | TabBarCoordinator     | | TabBarEmbeddable  -(push)-> | FlowCoordinator->Void           -(push)-> | Coordinator(String)             | | Coordinator(String)   |
     |-----------------------| |-----------------------------|-------------------------|-----------------|---------------------------------| |-----------------------|
     | TabBarController      | | (Nav) _ _ _ _     -(push)-> | (Nav) _ _ _ _ _ _ _ _ _ |_ _ _ _ _ _ _ _ _|_ _ _ _ _ _ _ _ _ _              | | (Nav) _ _ _ _         |
     |                       | | EmbeddedVC   \              | EmbeddedVC    -(push)-> | VC    -(push)-> | EmbeddedVC        \             | | EmbeddedVC   \        |
     |                       | ------------------------------------------------------------------------------------------------------------- |                       |
     |                       | ____________________________________________________________________________________________________________  |                       |
     |                       | | TabBarEmbeddable                                                                               -(modal)-> |                         |
     |                       | |-----------------------------------------------------------------------------------------------------------|                         |
     |                       | | VC                                                                                             -(modal)-> |                         |
     |                       | |                                                                                                           |                         |
     ------------------------- ---------------------------------------------------------------------------------------------------------------------------------------
     */
    func testTabBarCoordinatorStack() {
        let tabBarController = UITabBarController()
        let tabModel = TabBarCoordinator.SetupModel(createCoordinators: [
            .embed(TestTabBarEmbeddable1.self),
            .embed(TestTabBarEmbeddable2.self)], tabBarController: tabBarController)
        let tabCoordinator = navigator.start(onWindow: window, firstCoordinator: TabBarCoordinator.self, with: tabModel)
        
        // setup the first tab
        
        let tab1_firstCoordinator: TestTabBarEmbeddable1 = tabCoordinator.tabbedCoordinators[0] as! TestTabBarEmbeddable1
        let tab1_firstVC: TestEmbeddedViewController = tab1_firstCoordinator.vc
        let tab1_firstNavController = tab1_firstVC.navigationController
        
        let tab1_secondVC = TestEmbeddedViewController()
        var tab1_secondCoordinator: TestFlowCoordinatorVoidCompletionModel!
        navigator.go(to: TestFlowCoordinatorVoidCompletionModel.self, by: .pushing, with: tab1_secondVC, parameters: .noAnimation, flowCompletion: { _, _ in })
            .configureCoordinator { tab1_secondCoordinator = $0 }
        
        let tab1_thirdVC = TestViewController()
        tab1_thirdVC.coordinator = tab1_secondCoordinator
        tab1_secondCoordinator.present(tab1_thirdVC, by: .pushing, parameters: .noAnimation)
        
        let tab1_fourthVC = TestEmbeddedViewController()
        var tab1_thirdCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (tab1_fourthVC, ""), parameters: .noAnimation)
            .configureCoordinator { tab1_thirdCoordinator = $0 }
        
        // check the navigator coordinator stack
        expect(self.navigator.coordinators).to(haveCount(4))
        expect(self.navigator.coordinators[0]).to(be(tabCoordinator))
        expect(self.navigator.coordinators[1]).to(be(tab1_firstCoordinator))
        expect(self.navigator.coordinators[2]).to(be(tab1_secondCoordinator))
        expect(self.navigator.coordinators[3]).to(be(tab1_thirdCoordinator))
        
        // check lifecycle call counts
        expect(tab1_secondCoordinator.createCallCount).to(equal(1))
        expect(tab1_thirdCoordinator.createCallCount).to(equal(1))
        expect(tab1_secondCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(tab1_thirdCoordinator.presentFirstVCCallCount).to(equal(1))
        
        // check coordinator and view controller relationships
        expect(tabCoordinator.viewControllers).to(haveCount(1))
        expect(tabCoordinator.viewControllers[0]).to(be(tabBarController))
        expect(tab1_firstVC.coordinator).to(be(tab1_firstCoordinator))
        expect(tab1_firstCoordinator.viewControllers).to(haveCount(1))
        expect(tab1_firstCoordinator.viewControllers[0]).to(be(tab1_firstVC))
        expect(tab1_secondVC.coordinator).to(be(tab1_secondCoordinator))
        expect(tab1_thirdVC.coordinator).to(be(tab1_secondCoordinator))
        expect(tab1_secondCoordinator.viewControllers).to(haveCount(2))
        expect(tab1_secondCoordinator.viewControllers[0]).to(be(tab1_secondVC))
        expect(tab1_secondCoordinator.viewControllers[1]).to(be(tab1_thirdVC))
        expect(tab1_fourthVC.coordinator).to(be(tab1_thirdCoordinator))
        expect(tab1_thirdCoordinator.viewControllers).to(haveCount(1))
        expect(tab1_thirdCoordinator.viewControllers[0]).to(be(tab1_fourthVC))
        
        // check view controller relationships to one another
        expect(tab1_firstNavController).toNot(beNil())
        expect(tab1_firstNavController?.viewControllers).toEventually(haveCount(4))
        expect(tab1_firstVC.navigationController).toEventually(be(tab1_firstNavController))
        expect(tab1_secondVC.navigationController).toEventually(be(tab1_firstNavController))
        expect(tab1_thirdVC.navigationController).toEventually(be(tab1_firstNavController))
        expect(tab1_fourthVC.navigationController).toEventually(be(tab1_firstNavController))
        
        // setup the second tab, then modally present the view controller
        
        self.navigator.switch(toTabFor: TestTabBarEmbeddable2.self)
        let tab2_firstCoordinator: TestTabBarEmbeddable2 = tabCoordinator.tabbedCoordinators[1] as! TestTabBarEmbeddable2
        let tab2_firstVC: TestViewController = tab2_firstCoordinator.vc
        
        let tab2_secondVC = TestEmbeddedViewController()
        var tab2_secondCoordinator: TestCoordinatorStringSetup!
        navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (tab2_secondVC, ""), parameters: .noAnimation)
            .configureCoordinator { tab2_secondCoordinator = $0 }
        let tab2_firstNavController = tab2_secondVC.navigationController
        
        // check the navigator coordinator stack
        expect(self.navigator.coordinators).to(haveCount(3))
        expect(self.navigator.coordinators[0]).to(be(tabCoordinator))
        expect(self.navigator.coordinators[1]).to(be(tab2_firstCoordinator))
        expect(self.navigator.coordinators[2]).to(be(tab2_secondCoordinator))
        
        // check coordinator and view controller relationships
        expect(tab2_firstVC.coordinator).to(be(tab2_firstCoordinator))
        expect(tab2_secondVC.coordinator).to(be(tab2_secondCoordinator))
        
        // check view controller relationships to one another
        expect(tab2_firstVC.navigationController).to(beNil())
        expect(tab2_firstNavController).toNot(beNil())
        expect(tab2_firstNavController?.viewControllers).to(haveCount(1))
        expect(tab2_secondVC.navigationController).to(be(tab2_firstNavController))
        
        // switch back to the first tab, ensuring that 1) the modally presented coordinator remains on the stack, and 2)
        // that the stack before this coordinator changes.
        self.navigator.switch(toTabFor: TestTabBarEmbeddable1.self)
        
        // check the navigator coordinator stack
        expect(self.navigator.coordinators).to(haveCount(5))
        expect(self.navigator.coordinators[0]).to(be(tabCoordinator))
        expect(self.navigator.coordinators[1]).to(be(tab1_firstCoordinator))
        expect(self.navigator.coordinators[2]).to(be(tab1_secondCoordinator))
        expect(self.navigator.coordinators[3]).to(be(tab1_thirdCoordinator))
        expect(self.navigator.coordinators[4]).to(be(tab2_secondCoordinator))
        
        // check lifecycle call counts
        expect(tab1_secondCoordinator.createCallCount).to(equal(1))
        expect(tab1_thirdCoordinator.createCallCount).to(equal(1))
        expect(tab1_secondCoordinator.presentFirstVCCallCount).to(equal(1))
        expect(tab1_thirdCoordinator.presentFirstVCCallCount).to(equal(1))
        
        // check coordinator and view controller relationships
        expect(tab1_firstVC.coordinator).to(be(tab1_firstCoordinator))
        expect(tab1_secondVC.coordinator).to(be(tab1_secondCoordinator))
        expect(tab1_thirdVC.coordinator).to(be(tab1_secondCoordinator))
        expect(tab1_fourthVC.coordinator).to(be(tab1_thirdCoordinator))
        
        // check view controller relationships to one another
        expect(tab1_firstNavController).toNot(beNil())
        expect(tab1_firstNavController?.viewControllers).to(haveCount(4))
        expect(tab1_firstVC.navigationController).to(be(tab1_firstNavController))
        expect(tab1_secondVC.navigationController).to(be(tab1_firstNavController))
        expect(tab1_thirdVC.navigationController).to(be(tab1_firstNavController))
        expect(tab1_fourthVC.navigationController).to(be(tab1_firstNavController))
        
        expect(tabBarController).to(be(self.window.rootViewController))
        
        // pop the modal to make sure the navigator removesthe view controller/coordinator properly
        self.navigator.goBack(toLast: TestTabBarEmbeddable1.self)
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
