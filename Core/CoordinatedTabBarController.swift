
import UIKit

protocol CustomCoordinatedTabBarController {
    
}

public class CoordinatedTabBarController: UITabBarController {
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
