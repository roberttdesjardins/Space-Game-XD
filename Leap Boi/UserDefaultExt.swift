//
//  UserDefaultExt.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-03-01.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import Foundation

extension UserDefaults{
    func setUserHighScores(array: [Int]){
        set(array, forKey: UserDefaultsKeys.userHighScores.rawValue)
    }

    func getUserHighScores() -> [Int]{
        return object(forKey: UserDefaultsKeys.userHighScores.rawValue) as? [Int] ?? [Int]()
    }
    
    func setUserCredits(credits: Int){
        set(credits, forKey: UserDefaultsKeys.userCredits.rawValue)
    }
    
    func getUserCredits() -> Int {
        return object(forKey: UserDefaultsKeys.userCredits.rawValue) as? Int ?? Int()
    }
    
    func setUserHealthUpgrades(numberOfHealthUpgrades: Int){
        set(numberOfHealthUpgrades, forKey: UserDefaultsKeys.userNumberOfHealthUpgrades.rawValue)
    }
    
    func getUserHealthUpgrades() -> Int {
        return object(forKey: UserDefaultsKeys.userNumberOfHealthUpgrades.rawValue) as? Int ?? Int()
    }
    
    
}

enum UserDefaultsKeys : String {
    case userHighScores
    case userCredits
    case userNumberOfHealthUpgrades
}
