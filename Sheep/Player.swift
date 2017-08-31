import UIKit

class Player: NSObject {
    var name:String!
    var score:Int16!
    var level:Int16!
    
    init(name: String, score: Int16, level: Int16) {
        self.name = name
        self.score = score
        self.level = level
    }
}

class FBPlayer {
    var name:String!
    var id:Int32!
    var rightAnswer:Int32!
    
    init(id: Int32, name: String) {
        self.name = name
        self.id = id
        self.rightAnswer = 0
    }
}

class FBGame {
    var id:Int32!
    var player1:FBPlayer!
    var player2:FBPlayer!
    var turn:Int32!
    var numbers = [Int32]()
    
    init(id: Int32, player1: FBPlayer) {
        self.id = id
        self.player1 = player1
        self.player2 = nil
        self.turn = 1
    }
    
    init(id: Int32, player1: FBPlayer, player2: FBPlayer, numbers: [Int32]) {
        self.id = id
        self.player1 = player1
        self.player2 = player2
        self.numbers = numbers
        self.turn = 1
    }
    
}
