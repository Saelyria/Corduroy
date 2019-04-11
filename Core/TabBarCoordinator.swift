
import UIKit

/**
 A protocol describing a coordinator that can be used as a 'root' coordinator for one of the tabs on a tab bar.
 
 Each tab on a tab bar controller must be coordinated by an object that conforms to this protocol. These tab coordinator
 objects are added as a kind of 'child' coordinator to a managing `TabBarCoordinator`, which is what the navigator will
 use to represent these tabbed 'child' coordinators on its navigation stack.
 */
public protocol TabBarEmbeddable: AnyCoordinator {    
    /**
     Called when the coordinator is embedded as a root coordinator in a tab bar.
     
     In this method, the coordinator must instantiate its first view controller and pass it into the given `embed`
     closure. This closure must be called by the end of this method, so cannot be called after any networking or
     other asynchronous work.
     
     A default implementation of this method is provided if the conforming type is a `UIViewController`.
     
     - parameter context: A context object containing the involved coordinators and other navigation details.
     */
    func start(context: NavigationContext, embeddingFirstViewControllerWith embed: (UIViewController) -> Void)
}

public extension TabBarEmbeddable where Self: UIViewController, Self: Coordinator {
    func start(context: NavigationContext, embeddingFirstViewControllerWith embed: (UIViewController) -> Void) {
        embed(self)
    }
}

public extension TabBarEmbeddable where Self: Coordinator {
    // Most of the time, when a coordinator is used as the root 'tab bar',
    func start(context: NavigationContext) {
        print("This method was given a default implementation that does nothing because '\(type(of: Self.self))' was declared as 'TabBarEmbeddable'. If you want this coordinator to be useable as both a root 'tab bar' item and as a normal coordinator that can be used in other flows, this method must be implemented.")
    }
}

/**
 A coordinator that encapsulates a tab bar controller.
 
 This object is used to represent a tab bar controller in the `Navigator` object's navigation stack. Each tab on this
 coordinator's managed `UITabBarController` is managed by an object conforming to `TabBarEmbeddable`. These 'child' tab
 coordinators' lifecycles are managed by this object, and any navigation method called made to their `navigator` objects
 are relayed through this object.
 
 This object is created with this list of tab coordinators that will be used to create and coordinate each of the tab
 controller's tabbed view controllers as part of its `SetupModel` type. In this model, it can also optionally be given a
 custom `UITabBarController` object that you setup. If a tab bar controller instance is not given, the coordinator will
 create a `UITabBarController` itself.
 */
@objc public final class TabBarCoordinator: NSObject, Coordinator, SubNavigating {
    /// The tab bar coordinator's navigator.
    public var navigator: Navigator!
    /// The tab bar controller given to the coordinator through its setup model that it coordinates.
    public private(set) var tabBarController: UITabBarController!
    /// The coordinators managing the tabbed view controllers.
    public private(set) var tabbedCoordinators: [TabBarEmbeddable] = []
    
    /// The index in the `TabBarEmbeddables` array for the currently active tab coordinator.
    public var selectedIndex: Int {
        get { return self.tabBarController.selectedIndex }
        set { self.tabBarController.selectedIndex = newValue }
    }
    /// The `TabBarEmbeddable` child that is coordinating the active tabbed view controller currently being displayed.
    public var activeTabbedCoordinator: TabBarEmbeddable {
        return self.tabbedCoordinators[self.selectedIndex]
    }
    
    // internal jagged array representing the current navigation stack for each tabbed coordinator. TabBarCoordinators
    // are 'sub-navigating', meaning they manage a portion of the full navigation stack and report the current portion
    // to their navigator when asked. The 'portion' that they report is the stack corresponding to the currently
    // selected tab.
    internal var stackForTabbedCoordinators: [[Navigation]] = []
    internal var navigationStack: [Navigation] {
        return self.stackForTabbedCoordinators[self.selectedIndex]
    }
    
    public static func create(with model: SetupModel, navigator: Navigator) -> TabBarCoordinator {
        let coordinator = TabBarCoordinator()
        coordinator.navigator = navigator
        
        let embeddedCoordinators = model.createCoordinators(navigator)
        guard embeddedCoordinators.isEmpty == false else {
            fatalError("A TabBarCoordinator must be given at least one TabBarEmbeddable.")
        }
        
        coordinator.tabBarController = model.tabBarController ?? UITabBarController()
        var viewControllers: [UIViewController] = []
        for embeddedCoordinator in embeddedCoordinators {
            if embeddedCoordinator is NavigationPreconditionRequiring {
                print("Preconditions on '\(type(of: embeddedCoordinator))' being used as an embedded coordinator on a tab bar are not accounted for.")
            }
            var returnedViewController: UIViewController?
            let navContext = NavigationContext(navigator: navigator, from: coordinator, to: embeddedCoordinator, by: .switchingToTab, params: .defaults)
            embeddedCoordinator.start(context: navContext, embeddingFirstViewControllerWith: { returnedViewController = $0 })
            guard let viewController = returnedViewController else {
                fatalError("A view controller must be provided to the 'embed' closure by the end of the 'start(context:embeddingFirstViewControllerWith:)' call")
            }
            let tabbedVC = coordinator.embedInNavControllerIfNeeded(viewController, presentMethod: .switchingToTab)
            viewControllers.append(tabbedVC)
            coordinator.tabbedCoordinators.append(embeddedCoordinator)
            coordinator.stackForTabbedCoordinators.append([])
        }
        coordinator.tabBarController.viewControllers = viewControllers
        coordinator.selectedIndex = 0

        return coordinator
    }
    
    public func start(context: NavigationContext) {
        self.present(self.tabBarController, context: context)
        // we wait until presentation to actually populate the 'navigation stack'
        for (i, tabbedCoordinator) in self.tabbedCoordinators.enumerated() {
            self.selectedIndex = i
            let navigation = Navigation(coordinator: tabbedCoordinator, presentMethod: .switchingToTab, parentCoordinator: self)
            self.stackForTabbedCoordinators[i].append(navigation)
            guard let vc = self.tabBarController.viewControllers?[i] else { return }
            tabbedCoordinator.present(vc, by: .switchingToTab)
        }
        self.selectedIndex = 0
        self.activeTabbedCoordinator.didBecomeActive(context: context)
    }
    
    internal func add(navigation: Navigation) {
        self.stackForTabbedCoordinators[self.selectedIndex].append(navigation)
    }
    
    internal func canManage(navigationDescribedBy context: NavigationContext) -> Bool {
        // view controller presentations that involve adding the presented view controller as a root to the window
        // cannot logically be handled by a tab bar controller. Modal view controllers cover tab bar controllers, so
        // a modally presented coordinator should be added as a stack item after anything the tab bar coordinator
        // manages (i.e. should be managed by the navigator).
        return context.requestedPresentMethod.style != .addAsWindowRootViewController
            && context.requestedPresentMethod.style != .modalPresentation
            && context.requestedPresentMethod.style != .addingToSplitView
    }
    
    internal func `switch`<T: TabBarEmbeddable>(to TabBarEmbeddable: T.Type) {
        guard let index = self.tabbedCoordinators.firstIndex(where: { $0 is T }) else {
            assertionFailure("The tab bar coordinator was not setup with an instance of the given TabBarEmbeddable type to switch to.")
            return
        }
        
        let coordinator = self.tabbedCoordinators[index]
        let context = NavigationContext(
            navigator: self.navigator,
            from: self.activeTabbedCoordinator,
            to: coordinator,
            by: .switchingToTab,
            params: .defaults)
        self.activeTabbedCoordinator.didBecomeInactive(context: context)
        self.selectedIndex = index
        coordinator.didBecomeActive(context: context)
    }
}

extension TabBarCoordinator: UITabBarControllerDelegate {
    @objc public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        for (i, tabCoordinator) in self.tabbedCoordinators.enumerated() {
            if viewController === tabCoordinator.viewControllers.first {
                let context = NavigationContext(
                    navigator: self.navigator,
                    from: self.activeTabbedCoordinator,
                    to: tabCoordinator,
                    by: .switchingToTab,
                    params: .defaults)
                self.activeTabbedCoordinator.didBecomeInactive(context: context)
                self.selectedIndex = i
                tabCoordinator.didBecomeActive(context: context)
                break
            }
        }
    }
}

public extension TabBarCoordinator {
    struct SetupModel {
        public class Embedder {
            fileprivate let navigator: Navigator
            fileprivate var createdCoordinators: [TabBarEmbeddable] = []
            
            fileprivate init(navigator: Navigator) {
                self.navigator = navigator
            }
            
            public func embed<C: Coordinator & TabBarEmbeddable>(_ coordinatorType: C.Type, model: C.SetupModel) {
                let coordinator = coordinatorType.create(with: model, navigator: self.navigator)
                self.createdCoordinators.append(coordinator)
            }
            
            public func embed<C: Coordinator & TabBarEmbeddable>(_ coordinatorType: C.Type) where C.SetupModel == Void {
                let coordinator = coordinatorType.create(with: (), navigator: self.navigator)
                self.createdCoordinators.append(coordinator)
            }
        }
        
        internal let createCoordinators: (Navigator) -> [TabBarEmbeddable]
        internal let tabBarController: UITabBarController?

        public init(_ createCoordinators: @escaping (Embedder) -> Void, tabBarController: UITabBarController? = nil) {
            self.createCoordinators = { navigator in
                let embedder = Embedder(navigator: navigator)
                createCoordinators(embedder)
                return embedder.createdCoordinators
            }
            self.tabBarController = tabBarController
        }
    }
}
