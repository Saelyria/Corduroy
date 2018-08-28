import UIKit

/**
 Describes a view controller that can be instantiated from a storyboard.
 */
public protocol UIStoryboardInitable where Self: UIViewController {
    /// The name of the storyboard file containing this view controller.
    static var storyboardName: String { get }
    /// The identifier of this view controller in its storyboard. Defaults to the name of the view controller.
    static var viewControllerId: String { get }
    /// The bundle this view controller's storyboard is found in. Defaults to the bundle of the view controller's file.
    static var bundle: Bundle { get }
}

public extension UIStoryboardInitable {
    static var viewControllerId: String {
        return String(describing: Self.self)
    }
    
    static var bundle: Bundle {
        return Bundle(for: Self.self)
    }
    
    /// Instantiates a new instance of this view controller from its storyboard.
    static func createFromStoryboard() -> Self {
        let storyboard: UIStoryboard = UIStoryboard(name: self.storyboardName, bundle: self.bundle)
        let viewController: Self = storyboard.instantiateViewController(withIdentifier: self.viewControllerId) as! Self
        return viewController
    }
}
