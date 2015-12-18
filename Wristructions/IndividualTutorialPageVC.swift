import UIKit

class IndividualTutorialPageVC: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var pageIndex:Int!
    var labelString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = labelString
    }
}