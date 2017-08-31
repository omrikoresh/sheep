import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
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
    
    var type, points, count:Int32!
    var wordsCount, randomNum:UInt32!
    var words = [String]()
    var numbers = [UInt32]()
    var chosenCell:GameCell!
    var timer:Timer!
    var flag:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initClouds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destViewController: EndViewController = segue.destination as! EndViewController
        destViewController.score = points
        destViewController.level = type
        print("1 prepare, dismissing")
//        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if timer != nil {
            timer.invalidate()
        }
        chosenCell = collectionView.cellForItem(at: indexPath) as! GameCell
        chosenCell.text.textColor = UIColor.red
        helpText.text = "בחר/י מילה והתאם/י תיבה"
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as! GameCell).text.textColor = UIColor.black
    }
    
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
    
    func finishTurn() -> Void {
        chosenCell.isHidden = true
        count = count + 1
        
        if flag {
            helpText.text = "תשובה נכונה!"
            points = points + 1
        } else {
            helpText.text = "תשובה לא נכונה!"
        }
        
        if count == 9 {
            helpText.text = "המשחק תם! כל הכבוד!"
            if timer != nil {
                timer.invalidate()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in
                self.performSegue(withIdentifier: "end", sender: self)
            })
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in
                self.helpText.text = "בחר מילה"
            })
        }
        chosenCell = nil
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUM_OF_ROW
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return NUM_OF_SEC
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath) as! GameCell
        cell.text.text = words.popLast()
        return cell
    }
    
    func checkWordIndex(word: String, start: Int, end: Int) -> Bool {
        let index = allWords.index(of: word)!
        if index >= start && index <= end {
            return true
        }
        return false
    }
    
    func initClouds() -> Void {
        if type == 1 {
            b3.setBackgroundImage(nil, for: .normal)
            b3.isEnabled = false
            b4.isEnabled = false
            b4.setBackgroundImage(nil, for: .normal)
            wordsCount = 20
        }
        else if type == 2 {
            wordsCount = 40
        }
        
        for _ in 1...9 {
            repeat {
                randomNum = arc4random_uniform(wordsCount)
            } while !isExist(num: randomNum, array: numbers)
            numbers.append(randomNum)
            words.append(allWords[Int(randomNum)])
        }
        points = 0
        count = 0
        flag = false
    }
    
    func isExist(num: UInt32, array: [UInt32]) -> Bool {
        for object in array {
            if num == object {
                return false
            }
        }
        return true
    }
}

class GameCell: UICollectionViewCell {
    @IBOutlet var cloud: UIImageView!
    @IBOutlet var text: UITextField!
    var index:IndexPath!
}
