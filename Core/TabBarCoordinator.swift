
import UIKit

/**
 A coordinator for a tab bar controller.
 
 This object is used to represent a tab bar controller in the navigation hierarchy. It is created with the
 list of `TabCoordinator` types that will be used to create and coordinate each of the tab controller's
 tabbed view controllers. It can also optionally be given a custom `UITabBarController` object that you setup.
 If a tab bar controller instance is not given, the coordinator will create a `UITabBarController` itself.
 */
public final class TabBarCoordinator: Coordinator {
    public typealias SetupModel = (tabCoordinators: [TabCoordinator.Type], tabController: UITabBarController?)
    
    public var navigator: Navigator!
    /// The tab bar controller given to the coordinator through its setup model.
    public private(set) var tabBarController: UITabBarController!
    /// The coordinators managing the tabbed view controllers.
    public private(set) var tabCoordinators: [TabCoordinator] = []
    
    public static func create(with model: SetupModel, navigator: Navigator) -> TabBarCoordinator {
        let coordinator = TabBarCoordinator()
        coordinator.navigator = navigator
        coordinator.tabBarController = model.tabController ?? UITabBarController()
        coordinator.tabCoordinators = model.tabCoordinators.map({ $0.create(navigator: navigator) })
        
        let viewControllers = coordinator.tabCoordinators.map({ $0.createViewController() })
        
        for tabCoordinator in model.tabCoordinators {
            
        }
        return coordinator
    }
    
    public func presentViewController(context: NavigationContext) {
        self.present(self.tabBarController, context: context)
    }
    
    public init() { }
}

public final class CoordinatedTabBarController: UITabBarController {
    private(set) var tabCoordinators: [TabCoordinator] = []
    private var tabCoordinatorTypes: [TabCoordinator.Type] = []
    
    internal var coordinatorForTabBarItem: [UITabBarItem: TabCoordinator] = [:]
    internal var navigator: Navigator! {
        didSet {
            self.tabCoordinators = self.tabCoordinatorTypes.map({ $0.create(navigator: self.navigator) })
            let viewControllers = self.tabCoordinators.map({ $0.createViewController() })
            self.viewControllers = viewControllers
            
            var i: Int = 0
            for item in self.tabBar.items! {
                self.coordinatorForTabBarItem[item] = tabCoordinators[i]
                i = i+1
            }
        }
    }
    
    public required init(tabCoordinators: [TabCoordinator.Type]) {
        super.init(nibName: nil, bundle: nil)
        self.tabCoordinatorTypes = tabCoordinators
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) cannot be used to instantiate a CoordinatedTabBarController; use init(tabCoordinators:) instead.")
    }
    
    public override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        
    }
}
