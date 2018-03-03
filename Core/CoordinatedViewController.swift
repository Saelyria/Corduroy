
import UIKit

/**
 A protocol that all view controller should implement. In most cases, implementation should be done by subclassing
 `CoordinatedViewController`.
 
 This protocol should only be directly conformed to (likely through an extension) when adding compatibility with
 Corduroy's navigation system to view controllers you cannot make subclasses of `CoordinatedViewController`.
 */
public protocol CoordinatedViewControllerProtocol where Self: UIViewController {
    var baseCoordinator: BaseCoordinator? { get }
    var presentMethod: PresentMethod! { get set }

    func informNavigatorAboutAppearance()
    func informNavigatorAboutDisappearance()
}

public extension CoordinatedViewControllerProtocol {
    func informNavigatorAboutAppearance() {
        self.baseCoordinator?.navigator.coordinatedViewControllerDidAppear(self)
    }

    func informNavigatorAboutDisappearance() {
        self.baseCoordinator?.navigator.coordinatedViewControllerDidDisappear(self)
    }
}

/**
 A base class that all view controllers in your app should inherit from.
 
 `CoordinatedViewController` is a concrete implementation of `CoordinatedViewControllerProtocol` that will automatically
 inform its coordinator's navigator about its appearance and disappearance in its `viewDidAppear` and
 `viewDidDisappear`.
 */
open class CoordinatedViewController: UIViewController, CoordinatedViewControllerProtocol {
    public var baseCoordinator: BaseCoordinator?
    public var presentMethod: PresentMethod!

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.informNavigatorAboutAppearance()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.informNavigatorAboutDisappearance()
    }
}

