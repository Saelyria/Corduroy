import UIKit

public final class SplitViewCoordinator: Coordinator, SubNavigating {
    /// The split view coordinator's navigator.
    public var navigator: Navigator!
    
    public private(set) var splitViewController: UISplitViewController!
    
    internal var detailStack: [Navigation] = []
    internal var navigationStack: [Navigation] {
        return self.detailStack
    }
    
    public static func create(with model: SetupModel, navigator: Navigator) -> SplitViewCoordinator {
        let coordinator = SplitViewCoordinator()
        coordinator.splitViewController = model.splitViewController ?? UISplitViewController()
        return coordinator
    }
    
    public func presentViewController(context: NavigationContext) {
        
    }
    
    func canManage(navigationDescribedBy context: NavigationContext) -> Bool {
        // view controller presentations that involve adding the presented view controller as a root to the window
        // cannot logically be handled by a tab bar controller. Modal view controllers cover split view controllers, so
        // a modally presented coordinator should be added as a stack item after anything the split view coordinator
        // manages (i.e. should be managed by the navigator).
        return context.requestedPresentMethod.style != .addAsWindowRootViewController
            && context.requestedPresentMethod.style != .modalPresentation
            && context.requestedPresentMethod.style != .tabBarControllerTabSwitch
    }
    
    func add(navigation: Navigation) {
        
    }
    
    public init() { }
}

public extension SplitViewCoordinator {
    public struct SetupModel {
        public let masterCoordinator: AnyCoordinator.Type
        public let detailCoordinator: AnyCoordinator.Type
        public let splitViewController: UISplitViewController?
        
        public init(master: AnyCoordinator.Type, detail: AnyCoordinator.Type, splitViewController: UISplitViewController? = nil) {
            self.masterCoordinator = master
            self.detailCoordinator = detail
            self.splitViewController = splitViewController
        }
    }
}
