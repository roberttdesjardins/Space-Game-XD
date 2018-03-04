//
//  Healpers.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-27.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import Foundation

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}


func setAlienHealth(alien: SKSpriteNode) {
    alien.userData?.setValue(3, forKey: "health")
}

func setAstroidHealth(astroid: SKSpriteNode) {
    astroid.userData?.setValue(10, forKey: "health")
}



func playerTakesDamage(damage: Int, view: UIView) {
    GameData.shared.playerHealth = GameData.shared.playerHealth - damage
    if (GameData.shared.playerHealth <= 0) {
        gameOver(view: view)
    }
}


func gameOver(view: UIView) {
    let scene = GameOverScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func startSceneLoad(view: UIView) {
    let scene = StartScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.presentScene(scene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
}

func gameSceneLoad(view: UIView) {
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.presentScene(scene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
}

func highScoreSceneLoad(view: UIView) {
    let scene = HighScoreScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func weaponSceneLoad(view: UIView) {
    let scene = WeaponScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func resetHealthandScore() {
    GameData.shared.playerScore = 0
    GameData.shared.playerHealth = 100
}


func formatHighScores(arrayOfScores: [Int]) {
    GameData.shared.playerHighScore = quicksort(arrayOfScores)
    GameData.shared.playerHighScore = Array(GameData.shared.playerHighScore.prefix(5))
}

func quicksort<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else { return a }
    
    let pivot = a[a.count/2]
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }
    
    return quicksort(greater) + equal + quicksort(less)
}

