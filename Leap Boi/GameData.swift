//
//  GameData.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-28.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import Foundation

class GameData {
    static let shared = GameData()
    var maxPlayerHealth = 100
    var playerHealth = 100
    var playerScore = 0
    var playerHighScore: [Int] = []
    var weaponChosen = "laser"
    var shieldAmount = 1000
    var shieldTime: TimeInterval = 10
    var creditsEarned: Int = 0
    var totalCredits: Int = 0
    
    private init() { }
}
