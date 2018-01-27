
import Corduroy
import XCTest
import Nimble

class NavigationParameterTests: XCTestCase {
    var defaultParameters: [NavigationParameterKey: Any] = [
        .modalTransitionStyle: UIModalTransitionStyle.coverVertical,
        .modalPresentationStyle: UIModalPresentationStyle.none,
        .animateTransition: true
    ]
    
    func testModalTransitionOverride() {
        let validStyleEntry: UIModalTransitionStyle = UIModalTransitionStyle.crossDissolve
        let invalidStyleEntry: String = ""
        
        let validParameters: [NavigationParameterKey: Any] = NavigationParameterKey.defaultParameters(
            withOverrides: [NavigationParameterKey.modalTransitionStyle: validStyleEntry])
        let expectedValidParameters: [NavigationParameterKey: Any] = [
            NavigationParameterKey.animateTransition: defaultParameters[.animateTransition]!,
            NavigationParameterKey.modalPresentationStyle: defaultParameters[.modalPresentationStyle]!,
            NavigationParameterKey.animateTransition: defaultParameters[.animateTransition]!
        ]
        
        expect(validParameters[.modalTransitionStyle]).to(beAnInstanceOf(UIModalTransitionStyle.self))
        expect(validParameters[.modalPresentationStyle]).to(beAnInstanceOf(UIModalPresentationStyle.self))
        
        expect(validParameters[.modalTransitionStyle] as? UIModalTransitionStyle)
            .to(equal(expectedValidParameters[.modalTransitionStyle] as? UIModalTransitionStyle))
    }
}
