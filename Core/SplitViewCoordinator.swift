import UIKit

public protocol SplitViewMasterCoordinator: AnyCoordinator {
    /**
     Creates an instance of the tab coordinator.
     - parameter tabBarCoordinator: The tab bar coordinator this coordinator is managed by.
     - parameter navigator: The navigator the coordinator should use to navigate from.
     */
    static func create(splitViewCoordinator: SplitViewCoordinator<Self>, navigator: Navigator) -> Self
    
    init()
    
    func presentDetailCoordinator(context: NavigationContext)
}

public final class SplitViewCoordinator<MasterCoordinatorType: SplitViewMasterCoordinator>: Coordinator, TabBarEmbeddable, SubNavigating {
    public var tabBarCoordinator: TabBarCoordinator?
    
    /// The split view coordinator's navigator.
    public var navigator: Navigator!
    
    public private(set) var splitViewController: UISplitViewController!
    
    internal var masterNavigation: Navigation!
    internal var detailNavigationStack: [Navigation] = []
    internal var navigationStack: [Navigation] {
        var stack: [Navigation] = [self.masterNavigation]
        stack.append(contentsOf: self.detailNavigationStack)
        return stack
    }
    
    public static func create(with model: Void, navigator: Navigator) -> SplitViewCoordinator<MasterCoordinatorType> {
        let coordinator = SplitViewCoordinator<MasterCoordinatorType>()
        coordinator.navigator = navigator
        coordinator.splitViewController = UISplitViewController()
        
        let masterCoordinator = MasterCoordinatorType.create(splitViewCoordinator: coordinator, navigator: navigator)
        coordinator.masterNavigation = Navigation(
            coordinator: masterCoordinator,
            presentMethod: .addingAsMaster(on: coordinator.splitViewController),
            parentCoordinator: coordinator)
        
        return coordinator
    }
    
    public func createViewController(forTabBar coordinator: TabBarCoordinator) -> UIViewController {
        return self.splitViewController
    }
    
    public func start(context: NavigationContext, embeddingFirstViewControllerWith embed: (UIViewController) -> Void) {
        embed(self.splitViewController)
    }
    
    public func start(context: NavigationContext) {
        self.present(self.splitViewController, context: context)
    }
    
    internal func startInTabBarEmbeddable() {
        
    }
    
    func canManage(navigationDescribedBy context: NavigationContext) -> Bool {
        // view controller presentations that involve adding the presented view controller as a root to the window
        // cannot logically be handled by a split view controller. Modal view controllers cover split view controllers,
        // so a modally presented coordinator should be added as a stack item after anything the split view coordinator
        // manages (i.e. should be managed by the navigator).
        return context.requestedPresentMethod.style != .addAsWindowRootViewController
            && context.requestedPresentMethod.style != .modalPresentation
            && context.requestedPresentMethod.style != .tabBarControllerTabSwitch
    }
    
    func add(navigation: Navigation) {
        
    }
    
    public init() { }
}

//public extension SplitViewCoordinator {
//    public struct SetupModel<MasterCoordinator, DetailCoordinator> {
//        public let masterCoordinator: SplitViewMasterCoordinator.Type
//        public let splitViewController: UISplitViewController?
//
//        public init(master: SplitViewMasterCoordinator.Type, detail: AnyCoordinator.Type, splitViewController: UISplitViewController? = nil) {
//            self.masterCoordinator = master
//            self.detailCoordinator = detail
//            self.splitViewController = splitViewController
//        }
//    }
//}

/**
 navigator.go(to: SplitViewCoordinator.self, by:
 */
