import UIKit
import SwiftUI

class SwiftUIListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backPrimary
        
        let swiftUIContainer = UIHostingController(rootView: SwiftUIListView())
        
        addChild(swiftUIContainer)
        view.addSubview(swiftUIContainer.view)
        
        swiftUIContainer.view.frame = view.bounds
        swiftUIContainer.didMove(toParent: self)

    }

}
