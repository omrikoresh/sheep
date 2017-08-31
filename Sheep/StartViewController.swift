import UIKit
import Darwin

class StartViewController: UIViewController {
    @IBOutlet var stackView1: UIStackView!
    @IBOutlet var stackView2: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView2.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destViewController: MainViewController!
        
        if segue.identifier == "beginners" {
            destViewController = segue.destination as! MainViewController
            destViewController.type = 1
        }
        
        if segue.identifier == "advanced" {
            destViewController = segue.destination as! MainViewController
            destViewController.type = 2
        }
    }

    @IBAction func newGameAction(_ sender: Any) {
        stackView1.isHidden = true
        stackView2.isHidden = false
    }

}
