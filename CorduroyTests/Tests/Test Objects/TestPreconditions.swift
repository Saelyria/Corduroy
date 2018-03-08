
import XCTest
import Nimble
import Corduroy

struct PreconditionFailedError: Error { }

final class PassingPrecondition: NavigationPrecondition {
    func evaluate(context: NavigationContext) throws { }
}

final class FailingPrecondition: NavigationPrecondition {
    func evaluate(context: NavigationContext) throws {
        throw PreconditionFailedError()
    }
}

final class PassingRecoveringPrecondition: RecoveringNavigationPrecondition {
    func evaluate(context: NavigationContext) throws { }
    
    func attemptRecovery(context: NavigationContext, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}

final class FailingRecoveringPrecondition: RecoveringNavigationPrecondition {
    func evaluate(context: NavigationContext) throws { }
    
    func attemptRecovery(context: NavigationContext, completion: @escaping (Error?) -> Void) {
        completion(PreconditionFailedError())
    }
}
