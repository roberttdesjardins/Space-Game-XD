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
    var backButton: SKSpriteNode! = nil
    var laserButton: SKSpriteNode! = nil
    var missileButton: SKSpriteNode! = nil
    
    override func didMove(to view: SKView) {
        createBackground()
        createUI()
    }

    func createBackground() {
        let background = SKSpriteNode(imageNamed: "starbackground")
        background.zPosition = 1
        background.size = CGSize(width: background.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
    func createUI() {
        let shortButtonWidth = size.width - 80
        let shortButtonHeight = shortButtonWidth * 0.2974683544
        createBackButton()
        createLaserButton(width: shortButtonWidth, height: shortButtonHeight)
        createMissileButton(width: shortButtonWidth, height: shortButtonHeight)
    }
    
    func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "back")
        backButton.zPosition = 2
        backButton.size = CGSize(width: 64, height: 64)
        backButton.position = CGPoint(x: backButton.frame.size.width / 2 + 20, y: backButton.frame.size.height / 2 + 20)
        addChild(backButton)
    }
    
    func createLaserButton(width: CGFloat, height: CGFloat) {
        laserButton = SKSpriteNode(imageNamed: "button_laser")
        laserButton.zPosition = 2
        laserButton.size = CGSize(width: width, height: height)
        laserButton.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * (3/4))
        addChild(laserButton)
    }
    
    func createMissileButton(width: CGFloat, height: CGFloat) {
        missileButton = SKSpriteNode(imageNamed: "button_missile")
        missileButton.zPosition = 2
        missileButton.size = CGSize(width: width, height: height)
        missileButton.position = CGPoint(x: frame.size.width / 2, y: laserButton.position.y - laserButton.size.height - 25)
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
