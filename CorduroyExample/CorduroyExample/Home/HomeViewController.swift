
import UIKit
import Corduroy

class HomeViewController: UIViewController, UIStoryboardInitable, NavigationControllerEmbedded {
    static let storyboardName: String = "Main"
    
    var coordinator: HomeCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.red
        
        let button = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 100))
        self.view.addSubview(button)
        button.setTitle("Go back", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        self.coordinator?.buttonPressed()
    }
}
