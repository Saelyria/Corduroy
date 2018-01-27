
import XCTest
import Nimble
import Corduroy

class NavigatorTests: XCTestCase {
    var navigator: Navigator!
    var window: UIWindow!
    var applicaton: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        self.navigator = Navigator()
        self.applicaton = XCUIApplication()
        
//        _ = self.window
    }
    
    override func tearDown() {
        super.tearDown()
        self.navigator = nil
//        self.window.rootViewController = nil
    }

    
    
    // MARK: Start method tests
    
    func testNavigatorStartFailsSecondCall() {
        navigator.start(onWindow: window, firstCoordinator: TestCoordinatorVoidSetup.self)
        expect {
            self.navigator.start(onWindow: self.window, firstCoordinator: TestCoordinatorVoidSetup.self)
        }.to(throwAssertion())
    }
    
    func testNavigatorStartFailsOnPreconditionRequiring() {
        expect {
            self.navigator.start(onWindow: self.window, firstCoordinator: TestPassingPreconditionRequiringCoordinator.self)
        }.to(throwAssertion())
    }
    

    
    // MARK: Go to coordinator methods tests
    
    func testGoToCoordinatorFailsWhenNotStarted() {
        expect {
            self.navigator.go(to: TestCoordinatorVoidSetup.self, by: .modallyPresenting)
        }.to(throwAssertion())
        
    }
    
    func testGoToCoordinatorFailsWhenNoViewController() {
        navigator.start(onWindow: window, firstCoordinator: TestCoordinatorVoidSetup.self)
        expect {
            self.navigator.go(to: TestCoordinatorVoidSetup.self, by: .modallyPresenting)
        }.to(throwAssertion())
    }
    
    func testGoToCoordinatorStack() {
        let firstCoordinatorVC = UIViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstCoordinatorVC)
        let secondCoordinatorVC = UIViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondCoordinatorVC)
        let thirdCoordinatorVC = UIViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdCoordinatorVC, ""))
        
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
        
        expect(firstCoordinatorVC.parent).to(be(self.navigator.rootViewController))
        expect(firstCoordinatorVC.presentedViewController).to(be(secondCoordinatorVC))
        //expect(secondCoordinatorVC.presentingViewController).toEventually(be(firstCoordinatorVC), timeout: 3)
    }
}
