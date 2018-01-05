
import Foundation

protocol SelfCoordinating: Coordinator where Self: UIViewController {
    
}

extension SelfCoordinating {
    var currentViewController: UIViewController {
        return self
    }
}
