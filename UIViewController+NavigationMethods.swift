
import Foundation

extension UIViewController {
    func navigate(to toVC: UIViewController, by navigationMethod: NavigationMethod, parameters: [NavigationParameter]) {
        if let presentMethod = navigationMethod as? PresentMethod {
            switch presentMethod {
            case .addingAsChild:
                self.addChildViewController(toVC)
                self.view.addSubview(toVC.view)
                toVC.view.frame = self.view.frame
                toVC.didMove(toParentViewController: self)
            case .modallyPresenting:
                self.present(toVC, animated: true, completion: nil)
            case .pushing:
                self.navigationController?.pushViewController(toVC, animated: true)
            }
        } else if let dismissMethod = navigationMethod as? DismissMethod {
            switch dismissMethod {
            case .removingFromParent: break
            case .modallyDismissing:
                self.dismiss(animated: true, completion: nil)
            case .popping:
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
