//
//  TestViewController.swift
//  TicTacToe
//
//  Created by Moreno on 11/11/2017.
//  Copyright © 2017 Moreno. All rights reserved.
//

import UIKit

class TrainController: UIViewController {
    
    @IBOutlet weak var agentXLabel: UILabel!
    @IBOutlet weak var agentOLabel: UILabel!
    @IBOutlet weak var iterationsLabel: UILabel!
    
    private let bgQueue = DispatchQueue(label: "Training")
    
    static let PlaySegue = "playGame"
    
    var estimations_x: [String: Float] = [String: Float]()
    var estimations_o: [String: Float] = [String: Float]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let player1 = Player()
        let player2 = Player()
        let judger = Judger(player1: player1, player2: player2)
        var itx = 0
        var player1Win = 0
        var player2Win = 0
        
        func train(iterations: Int) -> Void {
            
            if itx == 10001 {
                self.estimations_x = player1.estimations
                self.estimations_o = player2.estimations
                self.performSegue(withIdentifier: TrainController.PlaySegue, sender: self)
                return
            }

            let update = { (winner: Int) in
                self.iterationsLabel.text = "Iterations: \(itx) / 10000"
                
                if winner == 1 {
                    player1Win += 1
                }
                else if winner == 2 {
                    player2Win += 1
                }
                
                self.agentXLabel.text = "Agent X: \(player1Win)"
                self.agentOLabel.text = "Agent O: \(player2Win)"
                judger.reset()
                itx += 1
                train(iterations: itx)
            }
    
            bgQueue.async {
                
                let winner = judger.play()
                
                
                DispatchQueue.main.async {
                    update(winner)
                }
                
                
            }
            
        }
        train(iterations: itx)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TrainController.PlaySegue {
            let vc = segue.destination as! RLController
            vc.estimations_x = self.estimations_x
            vc.estimations_o = self.estimations_o
        }
    }
    
    

}



class RLController: UIViewController {
    
    let player = Player()
    var opponent = Player(exploreRate: 0)
    var plSymbol = 1
    var oppSymbol = 2
    var currentState = State()
    var allStates = getAllStates()
    
    var estimations_x: [String: Float] = [String: Float]()
    var estimations_o: [String: Float] = [String: Float]()
    
    @IBOutlet weak var aiLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    
    var aiScore: Int = 0
    var playerScore: Int = 0
    
    
    private var current: Player? {
        
        didSet {
            if current != nil && current!.symbol == opponent.symbol {
                let action = self.current!.takeAction()
                self.play(move: action[0], player: self.current!)
            }
        }
    }
    
    
    private func opposite(player: Player) -> Player {
        
        if player.symbol == self.player.symbol {
            return self.opponent
        } else {
            return self.player
        }
    }
    
    
    
    @IBAction func symbol(_ sender: UIButton) {
        
        if (sender.currentBackgroundImage == nil && current?.symbol == self.player.symbol) {
            self.play(move: sender.tag-1, player: self.player)
        }
    }
    
    
    func play(move: Int, player: Player) {

        self.currentState = self.currentState.nextState(index: move, symbol: player.symbol)
        let hashValue = self.currentState.getHash()
        self.currentState = (self.allStates[hashValue]?.currentState)!
        let isEnd = self.allStates[hashValue]?.isEnd
        self.opponent.feedState(state: self.currentState)
        
        var img: UIImage!
        if current?.symbol == 1 {
            img = UIImage(named: "x.png")
        } else {
            img = UIImage(named: "o.png")
        }
        
        let temp = self.view.viewWithTag(move+1) as? UIButton
        temp?.setBackgroundImage(img, for: UIControlState.disabled)
        temp?.isEnabled = false
        
        if isEnd! {
            endMsg(winner: self.currentState.winner)
        } else {
            self.current = self.opposite(player: player)
        }
    }
    
    
    func resetBoard() {
        
        for i in 0...8 {
            let temp = self.view.viewWithTag(i+1) as? UIButton
            temp?.setBackgroundImage(nil, for: UIControlState.disabled)
            temp?.isEnabled = true
        }
        
        if self.plSymbol == 1 {
            self.plSymbol = 2
            self.oppSymbol = 1
        } else {
            self.plSymbol = 1
            self.oppSymbol = 2
        }
        self.aiLabel.text = "AI: \(self.aiScore)"
        self.playerLabel.text = "Player: \(self.playerScore)"
        self.startGame()
    }
    
    
    func updateScore() {
        
        if self.current?.symbol == self.player.symbol {
            self.playerScore += 1
        } else {
            self.aiScore += 1
        }
    }
    
    
    func startGame() {
        
        self.currentState = State()
        self.opponent.reset()
        self.player.setSymbol(symbol: self.plSymbol)
        self.opponent.setSymbol(symbol: self.oppSymbol)
        self.opponent.feedState(state: self.currentState)
        if self.opponent.symbol == 1 {
            self.opponent.estimations = self.estimations_x
            self.current = self.opponent
        } else {
            self.opponent.estimations = self.estimations_o
            self.current = self.player
        }
        
    }
    
    
    func endMsg(winner: Int) {
        
        var alertMsg: UIAlertController
        var msgText: String = ""
        var msgTitle: String = ""
        
        if winner == 1 || winner == 2 {
            
            self.updateScore()
            msgTitle = "Winner"
            if winner == 1 {
                msgText = "The winner is X"
            } else {
                msgText = "The winner is O"
            }
            
        } else {
            msgTitle = "Draw"
            msgText = "Draw"
        }
        
        alertMsg = UIAlertController(title: msgTitle, message: msgText, preferredStyle: UIAlertControllerStyle.alert)
        alertMsg.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in                self.resetBoard()
        }))
        self.present(alertMsg, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.aiLabel.text = "AI: \(aiScore)"
        self.playerLabel.text = "Player: \(playerScore)"
        startGame()
        
        
    }
    
}
