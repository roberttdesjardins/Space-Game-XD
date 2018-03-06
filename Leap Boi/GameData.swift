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
    var maxPlayerHealth = 10000
    var playerHealth = 10000
    var playerScore = 0
    var playerHighScore: [Int] = []
    var weaponChosen = "laser"
    
    private init() { }
}
