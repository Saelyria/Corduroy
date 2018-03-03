
import UIKit

public class CoordinatedViewController: UIViewController, CoordinatedViewControllerProtocol {
    public var baseCoordinator: BaseCoordinator?
    public var presentMethod: PresentMethod!
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baseCoordinator?.navigator.coordinatedViewControllerDidAppear(self)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.baseCoordinator?.navigator.coordinatedViewControllerDidDisappear(self)
    }
}
