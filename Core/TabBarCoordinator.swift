
import UIKit

/**
 A protocol describing an object that manages navigation for the view controller of one of the tab bar buttons.
 
 Each tab on a tab bar controller must be coordinated by an object that conforms to this protocol. These tab coordinator
 objects are added as a kind of 'child' coordinator to a managing `TabBarCoordinator`, which is what the navigator will
 use to represent these tabbed 'child' coordinators on its navigation stack.
 */
public protocol TabCoordinator: AnyCoordinator {
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
    /// The tab bar coordinator's navigator.
    public var navigator: Navigator!
    /// The tab bar controller given to the coordinator through its setup model that it coordinates.
    public private(set) var tabBarController: UITabBarController!
    /// The coordinators managing the tabbed view controllers.
    public private(set) var tabCoordinators: [TabCoordinator] = []
    
    /// The index in the `tabCoordinators` array for the currently active tab coordinator.
    public var selectedIndex: Int {
        get { return self.tabBarController.selectedIndex }
        set { self.tabBarController.selectedIndex = newValue }
    }
    /// The `TabCoordinator` child that is coordinating the active tabbed view controller currently being displayed.
    public var activeTabCoordinator: TabCoordinator {
        return self.tabCoordinators[self.selectedIndex]
    }
    
    // internal jagged array representing the current navigation stack for each tabbed coordinator. TabBarCoordinators
    // are 'sub-navigating', meaning they manage a portion of the full navigation stack and report the current portion
    // to their navigator when asked. The 'portion' that they report is the stack corresponding to the currently
    // selected tab.
    internal var stackForTabCoordinator: [[Navigation]] = []
    internal var navigationStack: [Navigation] {
        return self.stackForTabCoordinator[self.selectedIndex]
    }
    
    public static func create(with model: SetupModel, navigator: Navigator) -> TabBarCoordinator {
        let coordinator = TabBarCoordinator()
        coordinator.navigator = navigator
        
        guard model.tabCoordinatorTypes.isEmpty == false else {
            fatalError("A TabBarCoordinator must be given at least one TabCoordinator.")
        }
        
        coordinator.tabBarController = model.tabBarController ?? UITabBarController()
        var viewControllers: [UIViewController] = []
        for tabCoordinatorType in model.tabCoordinatorTypes {
            let tabCoordinator: TabCoordinator = tabCoordinatorType.create(tabBarCoordinator: coordinator, navigator: navigator)
            let viewController: UIViewController = tabCoordinator.createViewController()
            let tabbedVC = coordinator.embedInNavControllerIfNeeded(viewController, presentMethod: .switchingToTab)
            viewControllers.append(tabbedVC)
            coordinator.tabCoordinators.append(tabCoordinator)
            coordinator.stackForTabCoordinator.append([])
        }
        coordinator.tabBarController.viewControllers = viewControllers
        coordinator.selectedIndex = 0

        return coordinator
    }
    
    public func presentViewController(context: NavigationContext) {
        self.present(self.tabBarController, context: context)
        // we wait until presentation to actually populate the 'navigation stack'
        for (i, tabCoordinator) in self.tabCoordinators.enumerated() {
            guard let vc = self.tabBarController.viewControllers?[i] else { return }
            let navigation = Navigation(coordinator: tabCoordinator, presentMethod: .switchingToTab, parentCoordinator: self)
            if let navController = vc as? UINavigationController {
                navigation.viewControllersAndPresentMethods.append((vc: navController.topViewController!, presentMethod: .switchingToTab))
            } else {
                navigation.viewControllersAndPresentMethods.append((vc: vc, presentMethod: .switchingToTab))
            }
            self.stackForTabCoordinator[i].append(navigation)
        }
        self.activeTabCoordinator.didBecomeActive(context: context)
    }
    
    internal func add(navigation: Navigation) {
        self.stackForTabCoordinator[self.selectedIndex].append(navigation)
    }
    
    internal func canManage(navigationDescribedBy context: NavigationContext) -> Bool {
        // view controller presentations that involve adding the presented view controller as a root to the window
        // cannot logically be handled by a tab bar controller. Modal view controllers cover tab bar controllers, so
        // a modally presented coordinator should be added as a stack item after anything the tab bar coordinator
        // manages (i.e. should be managed by the navigator).
        return context.requestedPresentMethod.style != .addAsWindowRootViewController
            && context.requestedPresentMethod.style != .modalPresentation
    }
    
    internal func `switch`<T: TabCoordinator>(to tabCoordinator: T.Type) {
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
        self.selectedIndex = index
        coordinator.didBecomeActive(context: context)
    }
    
    public init() { }
}

public extension TabBarCoordinator {
    public struct SetupModel: ExpressibleByArrayLiteral {
        public typealias ArrayLiteralElement = TabCoordinator.Type
        
        public let tabCoordinatorTypes: [TabCoordinator.Type]
        public let tabBarController: UITabBarController?
        
        public init(arrayLiteral elements: TabCoordinator.Type...) {
            self.tabCoordinatorTypes = elements
            self.tabBarController = nil
        }
        
        public init(tabCoordinators: [TabCoordinator.Type], tabBarController: UITabBarController?) {
            self.tabCoordinatorTypes = tabCoordinators
            self.tabBarController = tabBarController
        }
    }
}
