
import XCTest
import Nimble
import Corduroy
@testable import CorduroyTests

/// Some tests commented out due to 'throwAssertion' testing not working.

class NavigatorTests: XCTestCase {
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

    
    
    // MARK: Start method tests
    
//    func testNavigatorStartFailsSecondCall() {
//        navigator.start(onWindow: window, firstCoordinator: TestCoordinatorVoidSetup.self)
//        expect {
//            self.navigator.start(onWindow: self.window, firstCoordinator: TestCoordinatorVoidSetup.self)
//        }.to(throwAssertion())
//    }
//
//    func testNavigatorStartFailsOnPreconditionRequiring() {
//        expect {
//            self.navigator.start(onWindow: self.window, firstCoordinator: TestPassingPreconditionRequiringCoordinator.self)
//        }.to(throwAssertion())
//    }
    

    
    // MARK: Go to coordinator methods tests
    
//    func testGoToCoordinatorFailsWhenNotStarted() {
//        expect {
//            self.navigator.go(to: TestCoordinatorVoidSetup.self, by: .modallyPresenting)
//        }.to(throwAssertion())
//
//    }
//
//    func testGoToCoordinatorFailsWhenNoViewController() {
//        navigator.start(onWindow: window, firstCoordinator: TestCoordinatorVoidSetup.self)
//        expect {
//            self.navigator.go(to: TestCoordinatorVoidSetup.self, by: .modallyPresenting)
//        }.to(throwAssertion())
//    }
    
    func testGoToCoordinatorStack() {
        let firstVC = UIViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = UIViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
        let thirdVC = UIViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
        
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
        expect(thirdVC.presentingViewController).to(be(secondVC))
    }
    
    func testGoBackStack() {
        let firstVC = UIViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = UIViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
        let thirdVC = UIViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
        
        navigator.goBack()
        
        expect(self.navigator.coordinators).to(haveCount(2))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        
        expect(thirdCoordinator.onDismissalCallCount).to(equal(1))
    }
    
    func testGoBackToStack() {
        let firstVC = UIViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = UIViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
        let thirdVC = UIViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
        let fourthVC = UIViewController()
        let fourthCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (fourthVC, ""))
        
        navigator.goBack(to: firstCoordinator)
        
        expect(self.navigator.coordinators).to(haveCount(1))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        
        expect(secondCoordinator.onDismissalCallCount).to(equal(1))
        expect(thirdCoordinator.onDismissalCallCount).to(equal(1))
        expect(fourthCoordinator.onDismissalCallCount).to(equal(1))
    }
    
    func testGoBackToLastStack() {
        let firstVC = UIViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstVC)
        let secondVC = UIViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondVC)
        let thirdVC = UIViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (thirdVC, ""))
        let fourthVC = UIViewController()
        let fourthCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .modallyPresenting, with: (fourthVC, ""))
        
        navigator.goBack(toLast: TestCoordinator.self)
        
        expect(self.navigator.coordinators).to(haveCount(2))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        expect(self.navigator.coordinators[1]).to(be(secondCoordinator))
        
        expect(thirdCoordinator.onDismissalCallCount).to(equal(1))
        expect(fourthCoordinator.onDismissalCallCount).to(equal(1))
        
        navigator.goBack(toLast: TestCoordinator.self)
        
        expect(self.navigator.coordinators).to(haveCount(1))
        expect(self.navigator.coordinators[0]).to(be(firstCoordinator))
        
        expect(secondCoordinator.onDismissalCallCount).to(equal(1))
    }
    
    func testGoToCoordinatorNavControllerStack() {
        let noAnimationParams = NavigationParameters(animateTransition: false)
        let firstVC = UIViewController()
        let navController = CoordinatedNavigationController(rootViewController: firstVC, navigator: self.navigator)
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: navController)
        let secondVC = UIViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .pushing, with: secondVC, parameters: noAnimationParams)
        let thirdVC = UIViewController()
        let thirdCoordinator = navigator.go(to: TestCoordinatorStringSetup.self, by: .pushing, with: (thirdVC, ""), parameters: noAnimationParams)
        let fourthVC = UIViewController()
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
}
