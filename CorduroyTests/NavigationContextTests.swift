
import XCTest
import Nimble
import Corduroy

class NavigationContextTests: XCTestCase {
    var navigator: Navigator!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        self.navigator = Navigator()
        self.window = UIWindow()
    }
    
    override func tearDown() {
        super.tearDown()
        self.navigator = nil
        self.window = nil
    }

    func testGoToCoordinatorContext() {
        let defaultParameters = NavigationParameters()
        let firstCoordinatorVC = UIViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstCoordinatorVC)
        
        expect(firstCoordinator.navContext.currentViewController).to(be(self.navigator.rootViewController))
        expect(firstCoordinator.navContext.fromCoordinator).to(beNil())
        expect(firstCoordinator.navContext.toCoordinator).to(be(firstCoordinator))
        expect(firstCoordinator.navContext.requestedPresentMethod).to(equal(PresentMethod.addingAsChild))
        expect(firstCoordinator.navContext.requestedDismissMethod).to(beNil())
        expect(firstCoordinator.navContext.parameters).to(equal(defaultParameters))
        expect(firstCoordinator.navContext.navigator).to(be(self.navigator))
        
        let secondCoordinatorVC = UIViewController()
        let secondCoordinator = navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondCoordinatorVC)
        
        expect(secondCoordinator.navContext.currentViewController).to(be(firstCoordinatorVC))
        expect(secondCoordinator.navContext.fromCoordinator).to(be(firstCoordinator))
        expect(secondCoordinator.navContext.toCoordinator).to(be(secondCoordinator))
        expect(secondCoordinator.navContext.requestedPresentMethod).to(equal(PresentMethod.modallyPresenting))
        expect(secondCoordinator.navContext.requestedDismissMethod).to(beNil())
        expect(secondCoordinator.navContext.parameters).to(equal(defaultParameters))
        expect(secondCoordinator.navContext.navigator).to(be(self.navigator))
    }
    
    func testGoBackContext() {
        
    }
}
