//
//  RLClasses.swift
//  TicTacToe
//
//  Created by Moreno on 12/11/2017.
//  Copyright © 2017 Moreno. All rights reserved.
//

import Foundation

let BOARD_SIZE = 9

class State {
    
    var data: [Int] = Array<Int>(repeating: 0, count: 9)
    var winner = 0
    var hashVal: String = ""
    var end: Bool? = nil
    
    typealias Pattern = (a: Int, b: Int, c: Int)
    static let Patterns: [Pattern] = [
        (0, 1, 2), (3, 4, 5), (6, 7, 8),
        (0, 3, 6), (1, 4, 7), (2, 5, 8),
        (0, 4, 8), (2, 4, 6)
    ]
    
    
    func getHash() -> String {
        self.hashVal = ""
        if self.hashVal.isEmpty {
            for mark in self.data {
                let m = String(mark)
                self.hashVal.append(m)
            }
        }
        return self.hashVal
    }
    
    
    func isEnd() -> Bool {
        
        if self.end != nil {
            return self.end!
        }
        
        for p: Pattern in State.Patterns {
            
            if self.data[p.a] != 0 && (self.data[p.a] == self.data[p.b] && self.data[p.b] == self.data[p.c]) {
                self.end = true
                self.winner = self.data[p.a]
                return self.end!
            }
        }
        
        if self.data.filter({$0 == 0}).count == 0 {
            self.end = true
            return self.end!
        }
        
        self.end = false
        return self.end!
        
    }
    
    
    func nextState(index: Int, symbol: Int) -> State {
        
        let newState = State()
        newState.data = self.data
        newState.data[index] = symbol
        return newState
        
    }
    
    
}


struct stateInfo {
    let currentState: State
    let isEnd: Bool
}

var allStates: [String: stateInfo] = [String: stateInfo]()

func getAllStatesImpl(currentState: State, currentSymbol: Int, allStates: inout [String: stateInfo]) {
    
    for i in 0..<BOARD_SIZE {
        
        if currentState.data[i] == 0 {
            
            let newState = currentState.nextState(index: i, symbol: currentSymbol)
            let newHash = newState.getHash()
            if allStates[newHash] == nil {
                let isEnd: Bool = newState.isEnd()
                allStates[newHash] = stateInfo(currentState: newState, isEnd: isEnd)
                if isEnd == false {
                    let cs = (currentSymbol == 1) ? 2 : 1
                    getAllStatesImpl(currentState: newState, currentSymbol: cs, allStates: &allStates)
                }
            }
        }
    }
}

func getAllStates() -> [String: stateInfo] {
    
    let currentSymbol = 1
    let currentState = State()
    var allStates: [String: stateInfo] = [String: stateInfo]()
    allStates[currentState.getHash()] = stateInfo(currentState: currentState, isEnd: currentState.isEnd())
    getAllStatesImpl(currentState: currentState, currentSymbol: currentSymbol, allStates: &allStates)
    return allStates
}



class Player {
    
    let stepSize: Float
    var exploreRate: Float
    var allStates: [String: stateInfo] = [String: stateInfo]()
    var estimations: [String: Float] = [String: Float]()
    var states: [State] = []
    var symbol: Int = 0
    
    
    init(stepSize: Float = 0.1, exploreRate: Float = 0.1) {
        
        self.stepSize = stepSize
        self.exploreRate = exploreRate
        self.allStates = getAllStates()
    }
    
    
    func reset() {
        self.states = []
    }
    
    
    func setSymbol(symbol: Int) {
        
        self.symbol = symbol
        for hash in self.allStates.keys {
            let state = self.allStates[hash]?.currentState
            let isEnd = self.allStates[hash]?.isEnd
            
            if isEnd! {
                if state!.winner == self.symbol {
                    self.estimations[hash] = 1.0
                } else {
                    self.estimations[hash] = 0
                }
            } else {
                self.estimations[hash] = 0.5
            }
        }
    }
    
    
    func feedState(state: State) {
        self.states.append(state)
    }
    
    
    func feedReward(reward: Float) {
        
        if self.states.count == 0 {
            return
        }
        var hash: [String] = []
        for state in self.states {
            hash.append(state.getHash())
        }
        var target = reward
        for latestState in hash.reversed() {
            let value = self.estimations[latestState]! + self.stepSize * (target - self.estimations[latestState]!)
            self.estimations[latestState] = value
            target = value
        }
        self.states = []
        
    }
    
    
    func takeAction() -> [Int] {
        
        let state = self.states.last
        var nextStates: [String] = []
        var nextPositions: [Int] = []
        
        for i in 0..<BOARD_SIZE {
            if state?.data[i] == 0 {
                nextPositions.append(i)
                nextStates.append((state?.nextState(index: i, symbol: self.symbol).getHash())!)
            }
        }
        if (Float(arc4random()) / Float(UInt32.max)) < self.exploreRate {
            let random = Int(arc4random_uniform(UInt32(nextPositions.count)))
            self.states = []
            let action = [nextPositions[random], self.symbol]
            return action
        }
        
        typealias Move = (hash: Float, index: Int)
        var values = [Move]()
        for (hash, pos) in zip(nextStates, nextPositions) {
            values.append((self.estimations[hash]!, pos))
        }
        values = values.sorted{ $0.hash > $1.hash }
        let action = [values.first?.index, self.symbol]
        return action as! [Int]
    }
}


class HumanPlayer {
    
    var symbol: Int = 0
    var currentState: State = State()
    
    func reset() {
        return
    }
    
    func setSymbol(symbol: Int) {
        self.symbol = symbol
    }
    
    func feedState(state: State) {
        self.currentState = state
    }
    
    func feedReward(reward: Float) {
        return
    }
    
    func takeAction() {
        // TODO: RETURN INDEX + SYMBOL
    }
    
}



class Judger {
    
    var p1: Player
    var p2: Player?
    var feedback: Bool
    var currentPlayer: Player?
    let p1Symbol = 1
    let p2Symbol = 2
    var humanP: HumanPlayer?
    
    var currentState = State()
    var allStates: [String: stateInfo]
    
    init(player1: Player, player2: Player, feedback: Bool = true) {
        self.p1 = player1
        self.p2 = player2
        self.feedback = feedback
        self.allStates = getAllStates()
        self.p1.setSymbol(symbol: self.p1Symbol)
        self.p2!.setSymbol(symbol: self.p2Symbol)
    }
    
    init(player1: Player, player2: HumanPlayer, feedback: Bool = false) {
        self.p1 = player1
        self.humanP = player2
        self.feedback = feedback
        self.allStates = getAllStates()
        self.p1.setSymbol(symbol: self.p1Symbol)
        self.humanP!.setSymbol(symbol: self.p2Symbol)
    }
    
    
    func giveReward() {
        
        if self.currentState.winner == self.p1Symbol {
            self.p1.feedReward(reward: 1)
            self.p2!.feedReward(reward: 0)
        }
        else if self.currentState.winner == self.p2Symbol {
            self.p1.feedReward(reward: 0)
            self.p2!.feedReward(reward: 1)
        }
        else {
            self.p1.feedReward(reward: 0.1)
            self.p2!.feedReward(reward: 0.5)
        }
    }
    
    
    func feedCurrentState() {
        self.p1.feedState(state: self.currentState)
        self.p2!.feedState(state: self.currentState)
    }
    
    
    func reset() {
        self.p1.reset()
        self.p2!.reset()
        self.currentState = State()
        self.currentPlayer = nil
    }
    
    
    func play(show: Bool = false) -> Int {
        
        self.reset()
        self.feedCurrentState()
        
        while true {
            
            if self.currentPlayer?.symbol == self.p1.symbol {
                self.currentPlayer = self.p2
            } else {
                self.currentPlayer = self.p1
            }
            let action = self.currentPlayer!.takeAction()
            self.currentState = self.currentState.nextState(index: action[0], symbol: action[1])
            let hashValue = self.currentState.getHash()
            self.currentState = (self.allStates[hashValue]?.currentState)!
            let isEnd = self.allStates[hashValue]?.isEnd
            self.feedCurrentState()
            if isEnd! {
                if self.feedback {
                    self.giveReward()
                }
                return self.currentState.winner
            }
        }
    }
    
    
    func playHuman() -> Int {
        var currentPlayer: Int = 1
        self.p1.reset()
        self.p1.feedState(state: self.currentState)
        
        while true {
            let action: [Int]
            if currentPlayer == self.p1.symbol{
                currentPlayer = humanP!.symbol
                action = self.currentPlayer!.takeAction()
            }  else {
                currentPlayer = self.p1.symbol
                action = self.p1.takeAction()
            }

            self.currentState = self.currentState.nextState(index: action[0], symbol: action[1])
            let hashValue = self.currentState.getHash()
            self.currentState = (self.allStates[hashValue]?.currentState)!
            let isEnd = self.allStates[hashValue]?.isEnd
            self.feedCurrentState()
            if isEnd! {
                return self.currentState.winner
            }
        }
    }
    
    
}


