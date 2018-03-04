//
//  WeaponScene.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-03-03.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


class WeaponScene: SKScene {
    let background = SKSpriteNode(imageNamed: "starbackground")
    var backButton: SKNode! = nil
    var laserButton: SKNode! = nil
    var missileButton: SKNode! = nil
    
    override func didMove(to view: SKView) {
        createBackground()
        createBackButton()
        createLaserButton()
        createMissileButton()
    }

    func createBackground() {
        let background = SKSpriteNode(imageNamed: "starbackground")
        background.zPosition = 1
        background.size = CGSize(width: background.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
    func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "backButton")
        backButton.zPosition = 2
        backButton.position = CGPoint(x: backButton.frame.size.width / 2 + 20, y: backButton.frame.size.height / 2 + 20)
        addChild(backButton)
    }
    
    func createLaserButton() {
        laserButton = SKSpriteNode(imageNamed: "laserButton")
        laserButton.zPosition = 2
        laserButton.position = CGPoint(x: frame.size.width / 4, y: frame.size.height * (3/4))
        addChild(laserButton)
    }
    
    func createMissileButton() {
        missileButton = SKSpriteNode(imageNamed: "missileButton")
        missileButton.zPosition = 2
        missileButton.position = CGPoint(x: frame.size.width * (3/4), y: frame.size.height * (3/4))
        addChild(missileButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if backButton.contains(touchLocation) {
            startSceneLoad(view: view!)
        }
        if laserButton.contains(touchLocation) {
            GameData.shared.weaponChosen = "laser"
            startSceneLoad(view: view!)
        }
        if missileButton.contains(touchLocation) {
            GameData.shared.weaponChosen = "missile"
            startSceneLoad(view: view!)
        }
        
    }

}
