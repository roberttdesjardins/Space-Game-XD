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
import AVFoundation

class StartScene: SKScene {
    let background = SKSpriteNode(imageNamed: "starbackground")
    var gameNameLabel: SKLabelNode! = nil
    var creditsLabel: SKLabelNode! = nil
    var startButton: SKSpriteNode! = nil
    var storeButton: SKSpriteNode! = nil
    var highScoreButton: SKSpriteNode! = nil
    var chooseWeaponButton: SKSpriteNode! = nil
    
    
    override func didMove(to view: SKView) {
        GameData.shared.playerHighScore = UserDefaults.standard.getUserHighScores()
        GameData.shared.totalCredits = UserDefaults.standard.getUserCredits()
        GameData.shared.numberOfHealthUpgrades = UserDefaults.standard.getUserHealthUpgrades()
        GameData.shared.numberOfShieldHealthUpgrades = UserDefaults.standard.getUserShieldHealthUpgrades()
        GameData.shared.numberOfShieldDurationUpgrades = UserDefaults.standard.getUserShieldDurationUpgrades()
        GameData.shared.shieldAmount = Double(100 + 20 * GameData.shared.numberOfShieldHealthUpgrades)
        GameData.shared.shieldTime = TimeInterval(10 + 5 * GameData.shared.numberOfShieldDurationUpgrades)
        GameData.shared.doubleLaserUpgrade = UserDefaults.standard.getUserDoubleLaserUpgrade()
        GameData.shared.homingMissileUpgrade = UserDefaults.standard.getUserHomingMissileUpgrade()
        GameData.shared.magnetUpgrade = UserDefaults.standard.getUserMagnetUpgrade()
        GameData.shared.startUpgradeBox = UserDefaults.standard.getUserStartBoxUpgrade()
        createBackground()
        if !GameData.shared.playingMenuMusic {
            setupMusic()
        }
        createUI()
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "starbackground")
        background.zPosition = 1
        background.size = CGSize(width: background.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
    func setupMusic() {
        let path = Bundle.main.path(forResource: "menu", ofType: "wav")!
        let url = URL(fileURLWithPath: path)
        do {
            GameData.shared.bgMusicPlayer = try AVAudioPlayer(contentsOf: url)
            GameData.shared.bgMusicPlayer.numberOfLoops = -1
            GameData.shared.bgMusicPlayer.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        GameData.shared.bgMusicPlayer.play()
        GameData.shared.playingMenuMusic = true
    }
    
    func createUI() {
        let shortButtonWidth = size.width * (9/12)
        let shortButtonHeight = shortButtonWidth * 0.2974683544
        let mediumButtonWidth = size.width * (9/12)
        let mediumButtonHeight = mediumButtonWidth * 0.2206047032
        createGameNameLabel()
        createStartButton(width: shortButtonWidth, height: shortButtonHeight)
        createCreditsLabel()
        createStoreButton(width: shortButtonWidth, height: shortButtonHeight)
        createHighScoreButton(width: mediumButtonWidth, height: mediumButtonHeight)
        createChooseWeaponButton(width: mediumButtonWidth, height: mediumButtonHeight)
        setLayout()
    }
    
    func createGameNameLabel() {
        gameNameLabel = SKLabelNode(fontNamed: "SquareFont")
        gameNameLabel.zPosition = 2
        gameNameLabel.fontSize = (55/414) * size.width
        gameNameLabel.fontColor = SKColor.white
        gameNameLabel.text = "Space Game xD"
        self.addChild(gameNameLabel)
    }
    
    func createStartButton(width: CGFloat, height: CGFloat) {
        startButton = SKSpriteNode(imageNamed: "button_play")
        startButton.zPosition = 2
        startButton.size = CGSize(width: width, height: height)
        addChild(startButton)
    }
    
    func createCreditsLabel() {
        creditsLabel = SKLabelNode(fontNamed: "SquareFont")
        creditsLabel.zPosition = 2
        creditsLabel.fontSize = 35
        creditsLabel.fontColor = SKColor.white
        creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
        self.addChild(creditsLabel)
    }
    
    func createStoreButton(width: CGFloat, height: CGFloat) {
        storeButton = SKSpriteNode(imageNamed: "button_store")
        storeButton.zPosition = 2
        storeButton.size = CGSize(width: width, height: height)
        addChild(storeButton)
    }
    
    func createHighScoreButton(width: CGFloat, height: CGFloat) {
        highScoreButton = SKSpriteNode(imageNamed: "button_high_scores")
        highScoreButton.zPosition = 2
        highScoreButton.size = CGSize(width: width, height: height)
        addChild(highScoreButton)
    }
    
    func createChooseWeaponButton(width: CGFloat, height: CGFloat) {
        chooseWeaponButton = SKSpriteNode(imageNamed: "button_choose_weapon")
        chooseWeaponButton.zPosition = 2
        chooseWeaponButton.size = CGSize(width: width, height: height)
        addChild(chooseWeaponButton)
    }
    
    func setLayout() {
        let spaceBetweenEach: CGFloat = size.height * 1/20
        
        if UIScreen.main.nativeBounds.height == 2436.0 {
            creditsLabel.position = CGPoint(x: size.width * 0.5, y: size.height * (9/10))
        } else {
            creditsLabel.position = CGPoint(x: size.width * 0.5, y: size.height - 40)
        }
        gameNameLabel.position = creditsLabel.position - CGPoint(x: 0, y: size.height * (1/8))
        
        chooseWeaponButton.position = CGPoint(x: size.width * 0.5, y: chooseWeaponButton.size.height/2 + spaceBetweenEach)
        highScoreButton.position = chooseWeaponButton.position + CGPoint(x: 0, y: chooseWeaponButton.size.height/2 + highScoreButton.size.height/2 + spaceBetweenEach)
        storeButton.position = highScoreButton.position + CGPoint(x: 0, y: highScoreButton.size.height/2 + storeButton.size.height/2 + spaceBetweenEach)
        startButton.position = storeButton.position + CGPoint(x: 0, y: storeButton.size.height/2 + startButton.size.height/2 + spaceBetweenEach)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if startButton.contains(touchLocation) {
            playButtonPress()
            gameSceneLoad(view: view!)
        }
        if storeButton.contains(touchLocation) {
            playButtonPress()
            storeSceneLoad(view: view!)
        }
        if highScoreButton.contains(touchLocation) {
            playButtonPress()
            highScoreSceneLoad(view: view!)
        }
        if chooseWeaponButton.contains(touchLocation) {
            playButtonPress()
            weaponSceneLoad(view: view!)
        }
    }
}

