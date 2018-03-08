//
//  StartScene.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-27.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class StartScene: SKScene {
    let background = SKSpriteNode(imageNamed: "starbackground")
    var startButton: SKSpriteNode! = nil
    var highScoreButton: SKSpriteNode! = nil
    var chooseWeaponButton: SKSpriteNode! = nil
    
    
    override func didMove(to view: SKView) {
        GameData.shared.playerHighScore = UserDefaults.standard.getUserHighScores()
        GameData.shared.totalCredits = UserDefaults.standard.getUserCredits()
        createBackground()
        createStartButton()
        createHighScoreButton()
        createChooseWeaponButton()
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "starbackground")
        background.zPosition = 1
        background.size = CGSize(width: background.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
    func createStartButton() {
        startButton = SKSpriteNode(imageNamed: "startButton")
        startButton.zPosition = 2
        startButton.position = CGPoint(x: size.width * 0.5, y: size.height * (2.0/3.0))
        addChild(startButton)
    }
    
    func createHighScoreButton() {
        highScoreButton = SKSpriteNode(imageNamed: "highScoresButton")
        highScoreButton.zPosition = 2
        highScoreButton.position = CGPoint(x: size.width * 0.5, y: size.height * (1.0/3.0))
        addChild(highScoreButton)
    }
    
    func createChooseWeaponButton() {
        chooseWeaponButton = SKSpriteNode(imageNamed: "chooseWeapon")
        chooseWeaponButton.zPosition = 2
        chooseWeaponButton.position = CGPoint(x: size.width * 0.5, y: 40)
        addChild(chooseWeaponButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if startButton.contains(touchLocation) {
            gameSceneLoad(view: view!)
        }
        if highScoreButton.contains(touchLocation) {
            highScoreSceneLoad(view: view!)
        }
        if chooseWeaponButton.contains(touchLocation) {
            weaponSceneLoad(view: view!)
        }
        
    }
    
}

