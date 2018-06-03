
import XCTest
import Nimble
@testable import Corduroy

class NavigationContextTests: XCTestCase {
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
        self.window = nil
    }

    func testGoToCoordinatorDefaultContext() {
        let defaultParameters = NavigationParameters()
        let firstCoordinatorVC = TestViewController()
        let firstCoordinator = navigator.start(onWindow: window, firstCoordinator: TestCoordinator.self, with: firstCoordinatorVC)
        
        expect(firstCoordinator.navContext.fromCoordinator).to(be(firstCoordinator))
        expect(firstCoordinator.navContext.toCoordinator).to(be(firstCoordinator))
        expect(firstCoordinator.navContext.parameters).to(equal(defaultParameters))
        expect(firstCoordinator.navContext.navigator).to(be(self.navigator))
        
        let secondCoordinatorVC = TestViewController()
        var secondCoordinator: TestCoordinator!
        navigator.go(to: TestCoordinator.self, by: .modallyPresenting, with: secondCoordinatorVC)
            .configureCoordinator { secondCoordinator = $0 }
        
        expect(secondCoordinator.navContext.fromCoordinator).toEventually(be(firstCoordinator))
        expect(secondCoordinator.navContext.toCoordinator).toEventually(be(secondCoordinator))
        expect(secondCoordinator.navContext.parameters).toEventually(equal(defaultParameters))
        expect(secondCoordinator.navContext.navigator).toEventually(be(self.navigator))
    }
    
    func testGoBackContext() {
        
    }
}

