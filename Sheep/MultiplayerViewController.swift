import UIKit
import FirebaseDatabase

class MultiplayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var phLabel: UILabel!
    
    var ref:DatabaseReference!
    var games:[FBGame] = []
    var player = [:] as [String : Any]
    var numbers = [:] as [String : Int32]
    var myGameId, myId, gameMaxId, player2GameId, playerMaxId:Int32!
    var myName, rivalName:String!
    var timer:Timer!
    var playerNum:Int32!
    var gameIsActive:Bool!
    
    override func viewDidLoad() {
        print("1 viewDidLoad")
        super.viewDidLoad()
        ref = Database.database().reference()
        myGameId = 0
        playerMaxId = 0
        gameMaxId = 0
        player2GameId = -1
        myName = ""
        gameIsActive = false
        initLists()
        stackView2.isHidden = true
        phLabel.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("1 viewWillDisappear")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("1 prepare")
        if segue.identifier == "mainMulti" {
            let destView:MainMultiViewController = segue.destination as! MainMultiViewController
            destView.gameId = myGameId
            destView.ref = ref
            destView.playerId = myId
            destView.playerNum = playerNum
            destView.rivalName = rivalName
        }
        gameIsActive = true

    }
    
    override func didReceiveMemoryWarning() {
        print("1 didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if gameIsActive == false{
            print("1 viewDidDisappear")
            if self.myGameId != 0 {
                print("1 viewDidDisappear #1")
                self.ref?.child("games").child(String(self.myGameId)).removeValue()
            }
            if self.myName != "" {
                print("1 viewDidDisappear #2")
                self.ref?.child("players").child(String(self.myId)).removeValue()
            }
        }
        ref.child("games").removeAllObservers()
        ref.child("players").removeAllObservers()
        ref.removeAllObservers()
    }
    
    @IBAction func addPlayerAction(_ sender: Any) {
        print("1 addPlayerAction")
        self.myName = textField.text
        
        if myName != "" {
            playerMaxId = playerMaxId + 1
            myId = playerMaxId
            self.player = ["name": myName, "id": myId, "rightAnswer" : 0, "playerNum" : 0, "points" : -1]
            self.numbers = ["junk" : 90]
            self.ref.child("players").child(String(myId)).setValue(player)
            
            textField.text = ""
            self.view.endEditing(true)
            
            stackView1.isHidden = true
            stackView2.isHidden = false
        }
    }
    
    @IBAction func addGameAction(_ sender: Any) {
        print("1 addGameAction")
        createNumbersArray()
        self.playerNum = 1
        self.gameMaxId = gameMaxId + 1
        self.myGameId = gameMaxId
        self.player["playerNum"] = 1
        let cell = ["cell1" : ["row" : -1, "section" : -1], "cell2" : ["row" : -1, "section" : -1]]
        let game = ["id": myGameId, "turn" : 1, "player1" : self.player, "numbers" : self.numbers, "cell" : cell, "endGame" : 0] as [String : Any]
        print("pre adding game")
        self.ref.child("games").child(String(myGameId)).setValue(game)
        print("post adding game")
        self.pleaseHoldLabel()
    }
    
    @IBAction func joinGameAction(_ sender: Any) {
        self.playerNum = 2
        self.ref.child("games").observe(.childAdded, with: { (snapshot) in
            print("1 joinGameAction #1")
            let value = snapshot.value as? NSDictionary
            let id = value?["id"] as? Int32
            let player1 = value?["player1"] as? NSDictionary
            self.rivalName = player1?["name"] as? String
            if id == self.myGameId {
                let player2 = value?["player2"] as? NSDictionary
                let name = player2?["name"] as? String
                if name != nil {
                    // player not added
                } else {
                    self.player["playerNum"] = 2
                    let values = ["player2" : self.player] as [String : Any]
                    self.ref.child("games").child(String(self.myGameId)).updateChildValues(values)
                    self.ref.removeAllObservers()
                    self.performSegue(withIdentifier: "mainMulti", sender: self)
                }
            }
        })
        
    }
    
    func pleaseHoldLabel() {
        print("1 pleaseHoldLabel")
        stackView1.isHidden = true
        stackView2.isHidden = true
        phLabel.isHidden = false
        var sec = 15
        
        self.ref.child("games").observe(.childChanged, with: { (snapshot) in
            print("1 pleaseHoldLabel #1")
            let value = snapshot.value as? NSDictionary
            let player2 = value?["player2"] as? NSDictionary
            if player2 != nil {
                self.rivalName = player2?["name"] as? String
                self.ref.removeAllObservers()
                self.performSegue(withIdentifier: "mainMulti", sender: self)
                self.timer.invalidate()
            }
        })
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            if self.playerNum == 1 {
                var str = "אנא המתן "
                
                if sec < 10 {
                    str += "00:0" + String(sec)
                } else {
                    str += "00:" + String(sec)
                }
                
                self.phLabel.text = str
                sec = sec - 1
                
                if sec == 0 {
                    self.multiGameFailed()
                }
            }
        })
    }
    
    func multiGameFailed() {
        print("1 multiGameFailed")
        timer.invalidate()
        phLabel.text = "נסה שוב"
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in
            if self.playerNum == 1 {
                self.ref?.child("games").child(String(self.myGameId)).removeValue()
            }
            self.ref?.child("players").child(String(self.myId)).removeValue()
            self.performSegue(withIdentifier: "start", sender: self)
        })
        
    }
    
    func initLists() {
        print("1 initLists")
        
        // fetch all players
        ref?.child("players").observe(.childAdded, with: { (snapshot) in
            print("1 initLists #1")
            let value = snapshot.value as? NSDictionary
            let id = value?["id"] as! Int32
            if self.playerMaxId < id {
                self.playerMaxId = id
            }
        })
        
        // fetch all games
        ref?.child("games").observe(.childAdded, with: { (snapshot) in
            print("1 initLists #2")
            let value = snapshot.value as? NSDictionary
            if (value?["endGame"] as? Int32) == -1 {
                return
            }
            let subValue = value?["player1"] as? NSDictionary
            let id = value?["id"] as! Int32
            let playerId = subValue?["id"] as! Int32
            let playerName = subValue?["name"] as! String
            let player1 = FBPlayer(id: playerId, name: playerName)
            
            if self.gameMaxId < id {
                self.gameMaxId = id
            }
            
            self.games.append(FBGame(id: self.gameMaxId, player1: player1))
            self.tableView.reloadData()
        })
        
        // fetch all removed players
        ref?.child("games").observe(.childRemoved, with: { (snapshot) in
            print("1 initLists #3")
            let value = snapshot.value as? NSDictionary
            let index:Int32 = self.findGameById(id: value?["id"] as! Int32)
            if index != -1 {
                self.games.remove(at: Int(index))
                self.tableView.reloadData()
            }
        })
        
        // a child can change only by adding player2
        ref?.child("games").observe(.childChanged, with: { (snapshot) in
            print("1 initLists #4")
            let value = snapshot.value as? NSDictionary
            self.player2GameId = value?["id"] as! Int32
            let index:Int32 = self.findGameById(id: self.player2GameId)
            if index != -1 {
                self.games.remove(at: Int(index))
                self.tableView.reloadData()
            }
        })
        
    }
    
    func findGameById(id: Int32) -> Int32 {
        print("1 findGameById")
        var index:Int32 = 0
        for game in games {
            if game.id == id {
                return index
            }
            index += 1
        }
        return -1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        let game = games[indexPath.row]
        let str:String = String(game.id) + " " + game.player1.name
        cell.textLabel?.text = str
        cell.textLabel?.textAlignment = .right
        
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let text = cell?.textLabel?.text
        let textArray = text?.components(separatedBy: " ")
        let id = textArray?[0]
        myGameId = Int32(id!)
    }
    
    func createNumbersArray() {
        let NUM_OF_WORDS:UInt32 = 40
        var randomNum:Int32!
        
        for index in 0...8 {
            repeat {
                randomNum = Int32(arc4random_uniform(NUM_OF_WORDS))
            } while !isExist(num: randomNum)
            self.numbers.updateValue(randomNum, forKey: String(index))
        }
    }
    
    func isExist(num: Int32) -> Bool {
        for object in self.numbers {
            if num == object.value{
                return false
            }
        }
        return true
    }
    
}



