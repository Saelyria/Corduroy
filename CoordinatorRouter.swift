
import Foundation

public struct NavigationContext {
    public let currentViewController: UIViewController
    public let fromCoordinator: BaseCoordinator
    public let toCoordinator: BaseCoordinator
}

public class CoordinatorRouter {
    public static let shared: CoordinatorRouter = CoordinatorRouter()
    
    public private(set) var currentCoordinator: BaseCoordinator?
    public let rootViewController: UIViewController = UIViewController()
    
    private var hasStarted: Bool = false
    
    public func start<T: Coordinator>(onWindow window: UIWindow, withCoordinator coordinator: T) where T.SetupContext == Void {
        self.start(onWindow: window, withCoordinator: coordinator, with: ())
    }
    
    public func start<T: Coordinator>(onWindow window: UIWindow, withCoordinator coordinator: T, with context: T.SetupContext) {
        guard self.hasStarted == false else {
            return
        }
        
        window.rootViewController = self.rootViewController
        window.makeKeyAndVisible()
        coordinator.start(with: context, from: self.rootViewController)
    }
    
    public func navigate<T: Coordinator, U: Coordinator>(to toCoordinator: T, from fromCoordinator: U) throws where T.SetupContext == Void {
        do {
            try self.navigate(to: toCoordinator, from: fromCoordinator, with: ())
        }
    }
    
    public func navigate<T: Coordinator, U: Coordinator>(to toCoordinator: T, from fromCoordinator: U, with context: T.SetupContext) throws {
        guard let viewController = fromCoordinator.currentViewController else {
            fatalError("No view controller set as 'currentViewController' on the presenting Coordinator.")
        }
        
        let navigationContext: NavigationContext = NavigationContext(currentViewController: viewController, fromCoordinator: fromCoordinator, toCoordinator: toCoordinator)
        var preconditionError: Error?
        for precondition: NavigationPrecondition in T.preconditions {
            precondition.evaluate(context: navigationContext, completion: { (error: Error?) in
                preconditionError = error
            })
        }
        
        if let error = preconditionError {
            throw error
        }
        
        self.currentCoordinator = toCoordinator
        toCoordinator.start(with: context, from: viewController)
    }
}
