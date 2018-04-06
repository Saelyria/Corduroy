
import XCTest
import Nimble
import Corduroy


final class PassingPrecondition: NavigationPrecondition {
    func evaluate(context: NavigationContext) throws { }
}

final class FailingPrecondition: NavigationPrecondition {
    func evaluate(context: NavigationContext) throws {
        throw self
    }
}

final class PassingRecoveringPrecondition: RecoveringNavigationPrecondition {
    func evaluate(context: NavigationContext) throws { }
    
    func attemptRecovery(context: NavigationContext, completion: @escaping (Bool) -> Void) -> PreconditionRecoveryMethod {
        completion(true)
        return .asyncTask
    }
}

final class FailingRecoveringPrecondition: RecoveringNavigationPrecondition {
    func evaluate(context: NavigationContext) throws { }
    
    func attemptRecovery(context: NavigationContext, completion: @escaping (Bool) -> Void) -> PreconditionRecoveryMethod {
        completion(false)
        return .asyncTask
    }
}
