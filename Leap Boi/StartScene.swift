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
    var storeButton: SKSpriteNode! = nil
    var highScoreButton: SKSpriteNode! = nil
    var chooseWeaponButton: SKSpriteNode! = nil
    
    
    override func didMove(to view: SKView) {
        GameData.shared.playerHighScore = UserDefaults.standard.getUserHighScores()
        GameData.shared.totalCredits = UserDefaults.standard.getUserCredits()
        GameData.shared.numberOfHealthUpgrades = UserDefaults.standard.getUserHealthUpgrades()
        createBackground()
        createGameNameLabel()
        createStartButton()
        createCreditsLabel()
        createStoreButton()
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
    
    func createGameNameLabel() {
        let gameNameLabel = SKLabelNode(fontNamed: "Avenir")
        gameNameLabel.zPosition = 2
        gameNameLabel.fontSize = 55
        gameNameLabel.fontColor = SKColor.white
        gameNameLabel.text = "Space Game xD"
        gameNameLabel.position = CGPoint(x: size.width/2, y: self.size.height * (5/6))
        
        self.addChild(gameNameLabel)
    }
    
    func createStartButton() {
        startButton = SKSpriteNode(imageNamed: "startButton")
        startButton.zPosition = 2
        startButton.position = CGPoint(x: size.width * 0.5, y: size.height * (4.0/6.0))
        addChild(startButton)
    }
    
    func createCreditsLabel() {
        let creditsLabel = SKLabelNode(fontNamed: "Avenir")
        creditsLabel.zPosition = 2
        creditsLabel.fontSize = 35
        creditsLabel.fontColor = SKColor.white
        creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
        creditsLabel.position = CGPoint(x: size.width/2, y: size.height * (3.0/6.0))
        
        self.addChild(creditsLabel)
    }
    
    func createStoreButton() {
        storeButton = SKSpriteNode(imageNamed: "storeButton")
        storeButton.zPosition = 2
        storeButton.position = CGPoint(x: size.width * 0.5, y: size.height * (2.0/6.0))
        addChild(storeButton)
    }
    
    func createHighScoreButton() {
        highScoreButton = SKSpriteNode(imageNamed: "highScoresButton")
        highScoreButton.zPosition = 2
        highScoreButton.position = CGPoint(x: size.width * 0.5, y: size.height * (1.0/6.0))
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
        if storeButton.contains(touchLocation) {
            storeSceneLoad(view: view!)
        }
        if highScoreButton.contains(touchLocation) {
            highScoreSceneLoad(view: view!)
        }
        if chooseWeaponButton.contains(touchLocation) {
            weaponSceneLoad(view: view!)
        }
        
    }
    
}

