
import XCTest
import Nimble
import Corduroy

struct PreconditionFailedError: Error { }

final class PassingPrecondition: NavigationPrecondition {
    func evaluate(context: Navigator.NavigationContext) throws { }
}

final class FailingPrecondition: NavigationPrecondition {
    func evaluate(context: Navigator.NavigationContext) throws {
        throw PreconditionFailedError()
    }
}

final class PassingRecoveringPrecondition: RecoveringNavigationPrecondition {
    func evaluate(context: Navigator.NavigationContext) throws { }
    
    func attemptRecovery(context: Navigator.NavigationContext, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}

final class FailingRecoveringPrecondition: RecoveringNavigationPrecondition {
    func evaluate(context: Navigator.NavigationContext) throws { }
    
    func attemptRecovery(context: Navigator.NavigationContext, completion: @escaping (Error?) -> Void) {
        completion(PreconditionFailedError())
    }
}
