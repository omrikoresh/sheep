import UIKit
import FirebaseDatabase

class MainMultiViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let NUM_OF_SEC = 3
    let NUM_OF_ROW = 3
    let SIZE = 9
    let allWords = ["ראש", "ילד", "רכב", "אופנוע", "טרקטור", "אוטובוס", "גרב", "מכנס", "פרח", "אגם",
                    "ילדה", "אצבע", "סירה", "ספינה", "בננה", "רוח", "עגבניה", "חולצה", "שעה", "דקה",
                    "חלון", "חול", "שולחן", "רחוב", "שיער", "כסא", "מזל", "נייר", "פרי", "לילה",
                    "שושנה", "תאנה", "שנה", "עין", "נעל", "ביצה", "פנינה", "ציפור", "עיר", "אבן",]
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var helpText: UILabel!
    @IBOutlet var b2: UIButton!
    @IBOutlet var b4: UIButton!
    @IBOutlet var b3: UIButton!
    @IBOutlet var b1: UIButton!
    
    var ref:DatabaseReference!
    var words = [String]()
    var chosenCell:GameCell!
    var numbers:NSDictionary!
    var timer:Timer!
    var count, points, playerNum, turn, gameId, playerId:Int32!
    var flag:Bool!
    var player = [:] as [String: Any]
    var rivalName:String!
    var row, section:Int!
    
    // override functions
    override func viewDidLoad() {
        print("2 viewDidLoad")
        super.viewDidLoad()
        turn = 1
        points = 0
        count = 0
        getDataFromFB()
        flag = false
        
        if self.playerNum == self.turn {
            self.enableButtonsFor(isEnable: true)
        } else {
            
            self.enableButtonsFor(isEnable: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        print("2 didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("2 prepare")
        let destView: EndViewController = segue.destination as! EndViewController
        destView.score = points
        destView.level = 3
        destView.playerId = playerId
        destView.ref = ref
        destView.gameId = gameId
        destView.playerNum = playerNum
        ref.child("games").removeAllObservers()
        ref.child("games").child(String(self.gameId)).removeAllObservers()
        ref.child("games").child(String(self.gameId)).child("cell").removeAllObservers()
    }
    
    func finishTurn() -> Void {
        print("2 finishTurn")
        
        if flag {
            self.points = points + 1
        }
        
        row = -1
        section = -1
        if self.playerNum == 1 {
            self.ref?.child("games").child(String(self.gameId)).child("cell").child("cell2").setValue(["row" : chosenCell.index.row, "section" : chosenCell.index.section])
        } else {
            self.ref?.child("games").child(String(self.gameId)).child("cell").child("cell1").setValue(["row" : chosenCell.index.row, "section" : chosenCell.index.section])
        }
        
        chosenCell.isHidden = true
        chosenCell = nil
        count = count + 1
        
        if self.turn == 1 {
            self.ref?.child("games").child(String(self.gameId)).child("turn").setValue(Int32(2))
        } else {
            self.ref?.child("games").child(String(self.gameId)).child("turn").setValue(Int32(1))
        }
        
        if self.playerNum == 1 && count == 5 {
            finishGame()
        } else if self.playerNum == 2 && count == 4 {
            finishGame()
        }
    }
    
    func finishGame() {
        print("2 finishGame")
        
        if self.playerNum == 1 {
            self.ref?.child("games").child(String(gameId)).child("player1").child("points").setValue(self.points)
        } else {
            self.ref?.child("games").child(String(gameId)).child("player2").child("points").setValue(self.points)
        }
        
        helpText.text = "סיימתם את כל המילים!"
        if timer != nil {
            timer.invalidate()
        }
    }
    
    func getDataFromFB() {
        print("2 getDataFromFB")
        self.ref?.child("games").child(String(self.gameId)).observeSingleEvent(of: .value, with: { (snapshot) in
            print("2 getDataFromFB #1")
            let value = snapshot.value as? NSDictionary
            self.numbers = value?["numbers"] as? NSDictionary
            for index in 0...8 {
                let num = Int(self.numbers?[String(index)] as! Int32)
                self.words.append(self.allWords[num])
            }
            self.words.sort()
            self.collectionView.reloadData()
        })
        
        self.ref?.child("games").child(String(self.gameId)).observe(.childChanged, with: { (snapshot) in
            print("2 getDataFromFB #3")
            let value = snapshot.value as? NSDictionary
            let turn = snapshot.value as? Int32
            let subValue:NSDictionary!
            if value?.count == 2 {
                print("2 getDataFromFB #3, cell")
                if self.playerNum == 1 {
                    subValue = value?["cell1"] as? NSDictionary
                } else {
                    subValue = value?["cell2"] as? NSDictionary
                }
                self.row = subValue?["row"] as! Int
                self.section = subValue?["section"] as! Int
                if self.row != -1 &&  self.section != -1 {
                    let cell = self.collectionView.cellForItem(at: IndexPath(row: self.row!, section: self.section!)) as? GameCell
                    cell?.isHidden = true
                    self.row = -1
                    self.section = -1
                }
            } else if turn == 1 || turn == 2 {
                print("2 getDataFromFB #3, turn")
                self.turn = turn
                if self.playerNum == self.turn {
                    self.enableButtonsFor(isEnable: true)
                } else {
                    self.enableButtonsFor(isEnable: false)
                }
            } else if value?.count == 5 {
                print("2 getDataFromFB #3, player")
                if value?["playerNum"] as? Int32 == 1 {
                    self.ref?.child("games").child(String(self.gameId)).child("endGame").setValue(Int32(-1))
                }
            } else if turn == -1 {
                print("2 getDataFromFB #3, end game")
                self.performSegue(withIdentifier: "end", sender: self)
            }
        })
        
    }
    
    func enableButtonsFor(isEnable: Bool) {
        print("2 enableButtonsFor")
        if isEnable {
            self.helpText.text = "בחר/י מילה והתאם/י תיבה"
        } else {
            self.helpText.text = "תורו/ה של " + self.rivalName
        }
        
        b1.isEnabled = isEnable
        b2.isEnabled = isEnable
        b3.isEnabled = isEnable
        b4.isEnabled = isEnable
    }
    
    func checkWordIndex(word: String, start: Int, end: Int) -> Bool {
        let index = allWords.index(of: word)!
        if index >= start && index <= end {
            return true
        }
        return false
    }
    
    // UI functions
    @IBAction func b1Action(_ sender: Any) {
        if chosenCell == nil {
            return
        }
        flag = checkWordIndex(word: chosenCell.text.text!, start: 0, end: 9)
        finishTurn()
    }
    
    @IBAction func b2Action(_ sender: Any) {
        if chosenCell == nil {
            return
        }
        flag = checkWordIndex(word: chosenCell.text.text!, start: 10, end: 19)
        finishTurn()
    }
    
    @IBAction func b3Action(_ sender: Any) {
        if chosenCell == nil {
            return
        }
        flag = checkWordIndex(word: chosenCell.text.text!, start: 20, end: 29)
        finishTurn()
    }
    
    @IBAction func b4Action(_ sender: Any) {
        if chosenCell == nil {
            return
        }
        flag = checkWordIndex(word: chosenCell.text.text!, start: 30, end: 39)
        finishTurn()
    }
    
    // collection view functions
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath) as! GameCell
        cell.text.text = words.popLast()
        cell.index = indexPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if timer != nil {
            timer.invalidate()
        }
        chosenCell = collectionView.cellForItem(at: indexPath) as! GameCell
        chosenCell.text.textColor = UIColor.red
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as! GameCell).text.textColor = UIColor.black
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUM_OF_ROW
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return NUM_OF_SEC
    }
}

