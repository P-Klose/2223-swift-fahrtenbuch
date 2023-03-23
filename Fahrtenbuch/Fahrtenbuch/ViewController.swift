import MapKit
import UIKit

class ViewController: UIViewController {
    
    private let mal: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    override func funx viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
        
    }
    
    override func viewDidLayoutSubviews() {
        map.frame = view.bounds
    }
    
}
