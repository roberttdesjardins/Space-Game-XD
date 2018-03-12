//
//  gameOverScene.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-27.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

class GameOverScene: SKScene {
    var restartButton: SKNode! = nil
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        GameData.shared.creditsEarned = GameData.shared.creditsEarned + Int(round(Double(GameData.shared.playerScore/250)))
        setupMusic()
        createGameOverLabel()
        createScoreLabel()
        createCreditsEarnedLabel()
        createRestartButton()
        GameData.shared.playerHighScore.append(GameData.shared.playerScore)
        formatHighScores(arrayOfScores: GameData.shared.playerHighScore)
        UserDefaults.standard.setUserHighScores(array: GameData.shared.playerHighScore)
        let newCreditBalance = GameData.shared.totalCredits + GameData.shared.creditsEarned
        UserDefaults.standard.setUserCredits(credits: newCreditBalance)
        print("Credits Earned = \(GameData.shared.creditsEarned)")
        print("Total Credits = \(UserDefaults.standard.getUserCredits())")
        resetGameData()
    }
    
    func setupMusic() {
        let path = Bundle.main.path(forResource: "in-the-wreckage", ofType: "wav")!
        let url = URL(fileURLWithPath: path)
        do {
            GameData.shared.bgMusicPlayer = try AVAudioPlayer(contentsOf: url)
            GameData.shared.bgMusicPlayer.numberOfLoops = -1
            GameData.shared.bgMusicPlayer.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        GameData.shared.bgMusicPlayer.play()
        GameData.shared.playingMenuMusic = false
    }
    
    func createGameOverLabel() {
        let gameOverLabel = SKLabelNode(fontNamed: "Courier")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.text = "You Died"
        gameOverLabel.position = CGPoint(x: self.size.width/2, y: 2.0 / 3.0 * self.size.height)
        
        self.addChild(gameOverLabel)
    }
    
    func createScoreLabel() {
        let scoreLabel = SKLabelNode(fontNamed: "Avenir")
        scoreLabel.fontSize = 35
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = "Score: \(GameData.shared.playerScore)"
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        self.addChild(scoreLabel)
    }
    
    func createCreditsEarnedLabel() {
        let creditsLabel = SKLabelNode(fontNamed: "Avenir")
        creditsLabel.fontSize = 35
        creditsLabel.fontColor = SKColor.white
        creditsLabel.text = "Credits Earned: \(GameData.shared.creditsEarned)"
        creditsLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        
        self.addChild(creditsLabel)
    }
    
    func createRestartButton() {
        restartButton = SKSpriteNode(imageNamed: "restartButton")
        restartButton.zPosition = 2
        restartButton.position = CGPoint(x: size.width/2, y: size.height/2 - 250)
        addChild(restartButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if restartButton.contains(touchLocation) {
            startSceneLoad(view: view!)
        }
    }
}
