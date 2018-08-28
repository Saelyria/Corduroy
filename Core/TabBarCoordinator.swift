
import UIKit

/**
 A protocol describing an object that manages navigation for the view controller of one of the tab bar buttons.
 
 Each tab on a tab bar controller must be coordinated by an object that conforms to this protocol. These tab coordinator
 objects are added as a kind of 'child' coordinator to a managing `TabBarCoordinator`, which is what the navigator will
 use to represent these tabbed 'child' coordinators on its navigation stack.
 */
public protocol TabCoordinator: BaseCoordinator {
    /// The tab bar coordinator object that manages this coordinator.
    var tabBarCoordinator: TabBarCoordinator! { get set }
    
    /**
     Creates an instance of the tab coordinator.
     - parameter tabBarCoordinator: The tab bar coordinator this coordinator is managed by.
     - parameter navigator: The navigator the coordinator should use to navigate from.
     */
    static func create(tabBarCoordinator: TabBarCoordinator, navigator: Navigator) -> Self
    
    init()
    
    /// Create the view controller that will be used for a tab on the tab bar. If the conforming type is a view
    /// controller that is coordinating itself, a default implementation of this method that simply returns the view
    /// controller is provided.
    func createViewController() -> UIViewController
}

public extension TabCoordinator {    
    static func create(tabBarCoordinator: TabBarCoordinator, navigator: Navigator) -> Self {
        let coordinator = Self()
        coordinator.tabBarCoordinator = tabBarCoordinator
        coordinator.navigator = navigator
        return coordinator
    }
}

public extension TabCoordinator where Self: UIStoryboardInitable {
    static func create(tabBarCoordinator: TabBarCoordinator, navigator: Navigator) -> Self {
        let coordinator = Self.createFromStoryboard()
        coordinator.tabBarCoordinator = tabBarCoordinator
        coordinator.navigator = navigator
        return coordinator
    }
}

public extension TabCoordinator where Self: UIViewController {
    func createViewController() -> UIViewController {
        return self
    }
}


/**
 A coordinator that represents a tab bar controller.
 
 This object is used to represent a tab bar controller in the `Navigator` object's navigation stack. Each tab on this
 coordinator's managed `UITabBarController` is managed by an object conforming to `TabCoordinator`. These 'child' tab
 coordinators' lifecycles are managed by this object, and any navigation method called made to their `navigator` objects
 are relayed through this object.
 
 This object is created with this list of tab coordinators that will be used to create and coordinate each of the tab
 controller's tabbed view controllers as part of its `SetupModel` type. In this model, it can also optionally be given a
 custom `UITabBarController` object that you setup. If a tab bar controller instance is not given, the coordinator will
 create a `UITabBarController` itself.
 */
public final class TabBarCoordinator: Coordinator, SubNavigating {
    public typealias SetupModel = (tabCoordinators: [TabCoordinator.Type], tabController: UITabBarController?)
    /// The tab bar coordinator's navigator.
    public var navigator: Navigator!
    /// The tab bar controller given to the coordinator through its setup model that it coordinates.
    public private(set) var tabBarController: UITabBarController!
    /// The coordinators managing the tabbed view controllers.
    public private(set) var tabCoordinators: [TabCoordinator] = []
    
    /// The index in the `tabCoordinators` array for the currently active tab coordinator.
    public var activeTabCoordinatorIndex: Int {
        return self.tabBarController.selectedIndex
    }
    /// The `TabCoordinator` child that is coordinating the active tabbed view controller currently being displayed.
    public private(set) var activeTabCoordinator: TabCoordinator!
    
    // internal jagged array representing the current navigation stack for each tabbed coordinator. TabBarCoordinators
    // are 'sub-navigating', meaning they manage a portion of the full navigation stack and report the current portion
    // to their navigator when asked.
    internal var stackForTabCoordinator: [[NavStackItem]] = []
    internal var managedNavigationStack: [NavStackItem] {
        return self.stackForTabCoordinator[self.activeTabCoordinatorIndex]
    }
    
    public static func create(with model: SetupModel, navigator: Navigator) -> TabBarCoordinator {
        let coordinator = TabBarCoordinator()
        coordinator.navigator = navigator
        
        guard model.tabCoordinators.isEmpty == false else {
            assertionFailure("A TabBarCoordinator must be given at least one TabCoordinator.")
            return coordinator
        }
        
        coordinator.tabBarController = model.tabController ?? UITabBarController()
        coordinator.tabCoordinators = model.tabCoordinators.map({ $0.create(tabBarCoordinator: coordinator, navigator: navigator) })
        coordinator.tabCoordinators.forEach({ $0.tabBarCoordinator = coordinator })
        let viewControllers = coordinator.tabCoordinators.map({ $0.createViewController() })
        coordinator.tabBarController.viewControllers = viewControllers
        coordinator.tabBarController.selectedIndex = 0
        coordinator.activeTabCoordinator = coordinator.tabCoordinators.first
        
        return coordinator
    }
    
    public func presentViewController(context: NavigationContext) {
        self.present(self.tabBarController, context: context)
        self.activeTabCoordinator.didBecomeActive(context: context)
    }
    
    public func `switch`<T: TabCoordinator>(to tabCoordinator: T.Type) {
        guard let index = self.tabCoordinators.firstIndex(where: { $0 is T }) else {
            assertionFailure("The tab bar coordinator was not setup with an instance of the given TabCoordinator type to switch to.")
            return
        }
        
        let coordinator = self.tabCoordinators[index]
        let context = NavigationContext(
            navigator: self.navigator,
            from: self.activeTabCoordinator,
            to: coordinator,
            by: .switchingToTab,
            params: NavigationParameters())
        self.activeTabCoordinator.didBecomeInactive(context: context)
        self.activeTabCoordinator = coordinator
        self.tabBarController.selectedIndex = index
        coordinator.didBecomeActive(context: context)
    }
    
    public init() { }
}
