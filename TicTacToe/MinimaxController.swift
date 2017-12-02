//
//  GameViewController.swift
//  TicTacToe
//
//  Created by Moreno on 26/10/2017.
//  Copyright © 2017 Moreno. All rights reserved.
//

import UIKit

let gameBoardSize = 9

class MinimaxController: UIViewController {
    
    var player = 1
    var board: [Int] = [Int](repeating: 0, count: gameBoardSize)
    let recursiveDepth = 8
    
    var HUMAN = true
    var game = 1

    enum gameScore: Int {
        case Zero = 0, Win = 10, Lose = -10
    }
    
    let CROSS: UIImage = UIImage(named: "x.png")!
    let CIRCLE: UIImage = UIImage(named: "o.png")!
    
    let wins = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    func minimax(gameBoard: [Int], depth: Int) -> Int {
        
        var bestMove: [Int] = []

        if player == 1 {
            var bestScore = Int.min
            for i in 0...8 {
                if gameBoard[i] == 0 {
                    var newBoard: [Int] = gameBoard
                    newBoard[i] = 1
                    let score = minValue(gameBoard: newBoard, depth: depth, alpha: gameScore.Lose.rawValue, beta: gameScore.Win.rawValue)
                    if score > bestScore {
                        bestMove.removeAll()
                        bestScore = score
                        bestMove.append(i)
                    } else if score == bestScore {
                        bestMove.append(i)
                    }
                    newBoard[i] = 0
                }
            }
        } else {
            var bestScore = Int.max
            for i in 0...8 {
                if gameBoard[i] == 0 {
                    var newBoard: [Int] = gameBoard
                    newBoard[i] = 2
                    let score = maxValue(gameBoard: newBoard, depth: depth, alpha: gameScore.Lose.rawValue, beta: gameScore.Win.rawValue)
                    if score < bestScore {
                        bestMove.removeAll()
                        bestScore = score
                        bestMove.append(i)
                    } else if score == bestScore {
                        bestMove.append(i)
                    }
                    newBoard[i] = 0
                }
            }
        }
        return bestMove.count > 0 ? bestMove[Int(arc4random()) % bestMove.count] : 0
    }
    
    
    func maxValue(gameBoard: [Int], depth: Int, alpha: Int, beta: Int) -> Int {
        
        let score = endScore(gameBoard: gameBoard)
        if (isGameOver(board: gameBoard) || depth == 0 || alpha >= beta) {
            return score
        }
        
        var bestValue = Int.min
        for i in 0...8 {
            if gameBoard[i] == 0 {
                var newBoard: [Int] = gameBoard
                newBoard[i] = 1
                let value = minValue(gameBoard: newBoard, depth: depth-1, alpha: max(bestValue, alpha), beta: beta)
                bestValue = max(value, bestValue)
                newBoard[i] = 0
            }
        }
        return bestValue
    }
    
    
    func minValue(gameBoard: [Int], depth: Int, alpha: Int, beta: Int) -> Int {
        
        let score = endScore(gameBoard: gameBoard)
        if (isGameOver(board: gameBoard) || depth == 0 || alpha >= beta) {
            return score
        }
        
        var bestValue = Int.max
        for i in 0...8 {
            if gameBoard[i] == 0 {
                var newBoard: [Int] = gameBoard
                newBoard[i] = 2
                let value = maxValue(gameBoard: newBoard, depth: depth-1, alpha: alpha, beta: min(bestValue, beta))
                bestValue = min(value, bestValue)
                newBoard[i] = 0
            }
        }
        return bestValue
    }
    
    
    func endScore(gameBoard: [Int]) -> Int {
        var score: Int = 0
        for indices in wins {
            if gameBoard[indices[0]] == 0 {
                continue
            }
            
            let square = gameBoard[indices[0]]
            if gameBoard[indices[0]] == gameBoard[indices[1]] && gameBoard[indices[0]] == gameBoard[indices[2]] {
                score = (square == 1) ? gameScore.Win.rawValue : gameScore.Lose.rawValue
            }
        }
        
        return score
    }
    
    
    func getWinner(board: [Int]) -> Int {
        if isWin(board: board) {
            for indices in wins {
                if board[indices[0]] == 0 {
                    continue
                }
                
                let winner: Int = board[indices[0]]
                if board[indices[0]] == board[indices[1]] && board[indices[1]] == board[indices[2]] {
                    return winner
                }
            }
        }
        return 0
    }
    
    
    @IBAction func simbol(_ sender: UIButton) {
        
        if (sender.currentBackgroundImage == nil && HUMAN) {
            var img: UIImage!
            if player == 1 {
                img = UIImage(named: "x.png")
            } else {
                img = UIImage(named: "o.png")
            }
            sender.setBackgroundImage(img, for: UIControlState.disabled)
            sender.isEnabled = false
            board[sender.tag-1] = player
            HUMAN = false
            changePlayer()
        }
    }
    
    
    func nextMove() -> Void {
        
        var img: UIImage!
        let index = self.minimax(gameBoard: board, depth: recursiveDepth)
        board[index] = player
        let btn = self.view.viewWithTag(index+1) as? UIButton
        if player == 1 {
            img = UIImage(named: "x.png")
        } else {
            img = UIImage(named: "o.png")
        }
        btn?.setBackgroundImage(img, for: UIControlState.disabled)
        btn?.isEnabled = false
        HUMAN = true
        changePlayer()
    }
    
    
    func changePlayer() -> Void {
        
        if isGameOver(board: board) {
            endMsg()
        } else {
            if player == 1 {
                player = 2
            } else {
                player = 1
            }
            if HUMAN == false {
                nextMove()
            }
            
        }
    }
    
    
    func isDraw(board: [Int]) -> Bool {
        
        for i in 0..<gameBoardSize {
            if board[i] == 0 {
                return false
            }
        }
        return true
    }
    
    
    func isWin(board: [Int]) -> Bool {
        
        for indices in wins {
            if board[indices[0]] == 0 {
                continue
            }
            
            if board[indices[0]] == board[indices[1]] && board[indices[1]] == board[indices[2]] {
                return true
            }
        }
        return false
    }
    
    
    func isGameOver(board: [Int]) -> Bool {
        return isWin(board: board) || isDraw(board: board)
    }
    
    
    func resetBoard() -> Void {
        
        for i in 0...8 {
            let temp = self.view.viewWithTag(i+1) as? UIButton
            temp?.setBackgroundImage(nil, for: UIControlState.disabled)
            temp?.isEnabled = true
            board[i] = 0
        }
        game += 1
        player = 1
        if game % 2 == 1 {
            HUMAN = true
        }
        else {
            HUMAN = false
            nextMove()
        }
        
    }
    
    
    func endMsg() {
        
        var alertMsg: UIAlertController
        if isWin(board: board) {
            if player == 1 {
                alertMsg = UIAlertController(title: "Winner", message: "The winner is X", preferredStyle: UIAlertControllerStyle.alert)
            } else {
                alertMsg = UIAlertController(title: "Winner", message: "The winner is O", preferredStyle: UIAlertControllerStyle.alert)
            }
        } else {
            alertMsg = UIAlertController(title: "Draw", message: "Draw", preferredStyle: UIAlertControllerStyle.alert)
        }
        
        alertMsg.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in                self.resetBoard()
        }))
        self.present(alertMsg, animated: true, completion: nil)
    }


}
