import UIKit
import CoreData
import FirebaseDatabase

class EndViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var startBttn: UIButton!
    @IBOutlet var scoreBttn: UIButton!
    @IBOutlet var label: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameField: UITextField!
    
    var ref:DatabaseReference!
    var context:NSManagedObjectContext!
    var request: NSFetchRequest<NSFetchRequestResult>!
    var appDelegate: AppDelegate!
    
    var score, level, gameId, playerId, playerNum:Int32!
    var winner:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if level == 3 {
            scoreBttn.isHidden = true
            startBttn.isHidden = false
            stackView.isHidden = true
            self.label.text = "מחשב תוצאות"
            checkForWinner()
        } else {
            appDelegate = UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.persistentContainer.viewContext
            request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
            request.returnsObjectsAsFaults = false
            label.text = "תוצאתך היא " + String(score)
            stackView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func scoreAction(_ sender: Any) {
        scoreBttn.isHidden = true
        startBttn.isHidden = true
        stackView.isHidden = false
    }
    
    @IBAction func nameOkAction(_ sender: Any) {
        let name = nameField.text
        if  name != "" {
            stackView.isHidden = true
            startBttn.isHidden = false
            addPlayerToDC(name: name!)
            nameField.resignFirstResponder()
        }
    }
    
    @IBAction func backToStartMenu(_ sender: Any) {
        print("3 backToStartMenu")    }
    
    func checkForWinner() {
        self.ref?.child("games").child(String(gameId)).observeSingleEvent(of: .value, with: { (snaphsot) in
            let value = snaphsot.value as? NSDictionary
            let player1 = value?["player1"] as? NSDictionary
            let player2 = value?["player2"] as? NSDictionary
            let points1 = (player1?["points"] as? Int32)!
            let points2 = (player2?["points"] as? Int32)!
            
            if points1 == -1 || points2 == -1 {
            } else if points1 > points2 {
                self.winner = player1?["name"] as? String
                self.label.text = "המנצח הוא " + self.winner!
            } else if points1 < points2 {
                self.winner = player2?["name"] as? String
                self.label.text = "המנצח הוא " + self.winner!
            } else {
                self.label.text = "המשחק תם בתיקו"
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.playerNum == 1 {
            self.ref?.child("games").child(String(self.gameId)).removeValue()
        }
        self.ref?.child("players").child(String(self.playerId)).removeValue()
        ref.child("games").removeAllObservers()
        ref.child("players").removeAllObservers()
        ref.removeAllObservers()
    }
    
    func addPlayerToDC(name: String) -> Void {
        let player = NSEntityDescription.insertNewObject(forEntityName: "Players", into: context)
        player.setValue(name, forKey: "name")
        player.setValue(self.score, forKey: "score")
        player.setValue(self.level, forKey: "level")
        do {
            try context.save()
        } catch {
            print("ERROR: addPlayerToDC")
        }
    }
}
