//
//  Healpers.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-27.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import Foundation

func setAlienHealth(alien: SKSpriteNode) {
    alien.userData?.setValue(3, forKey: "health")
}

func setAstroidHealth(astroid: SKSpriteNode) {
    astroid.userData?.setValue(10, forKey: "health")
}

func subtractHealth(sprite: SKNode, damage: Int) {
    let currentHealth: Int = sprite.userData?.value(forKey: "health") as! Int
    let newHealth = currentHealth - damage
    sprite.userData?.setValue(newHealth, forKey: "health")
    //print(newHealth)
    if (newHealth <= 0) {
        sprite.removeFromParent()
        //print("Should die")
    }
}

func gameOver(view: UIView) {
    let scene = GameOverScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.presentScene(scene)
}

func startSceneLoad(view: UIView) {
    let scene = StartScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.presentScene(scene)
}
