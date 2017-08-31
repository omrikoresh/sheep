import UIKit
import CoreData

class ScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var players:[Player] = []
    var results:[Any] = []
    var context:NSManagedObjectContext!
    var request: NSFetchRequest<NSFetchRequestResult>!
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
        request.returnsObjectsAsFaults = false
        loadScoresIntoPlayers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        let player = players[indexPath.row]
        var str:String = player.name + " - " + String((player.score)!)
        if player.level == 1 {
            str.append(" - מתחילים")
        } else {
            str.append(" - מתקדמים")
        }
        cell.textLabel?.text = str
        cell.textLabel?.textAlignment = .right
        
        return(cell)
    }
    
    @IBAction func backToMainMenu(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    func loadScoresIntoPlayers() -> Void {
        do {
            results = try context.fetch(request)
            for result in results as! [NSManagedObject] {
                let name = (result.value(forKey: "name") as? String)!
                let score = (result.value(forKey: "score") as? Int16)!
                let level = (result.value(forKey: "level") as? Int16)!
                players.append(Player(name: name, score: score, level: level))
            }
        } catch {
            print("ERROR: loadScoresIntoArray")
        }
    }


}
