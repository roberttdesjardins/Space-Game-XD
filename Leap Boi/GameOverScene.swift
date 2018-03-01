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

class GameOverScene: SKScene {
    var restartButton: SKNode! = nil
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        createGameOverLabel()
        createScoreLabel()
        createRestartButton()
        GameData.shared.playerHighScore.append(GameData.shared.playerScore)
        formatHighScores(arrayOfScores: GameData.shared.playerHighScore)
        UserDefaults.standard.setUserHighScores(array: GameData.shared.playerHighScore)
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
    
    func createRestartButton() {
        restartButton = SKSpriteNode(imageNamed: "restartButton")
        restartButton.zPosition = 2
        restartButton.position = CGPoint(x: size.width/2, y: size.height * (1/3))
        addChild(restartButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if restartButton.contains(touchLocation) {
            resetHealthandScore()
            startSceneLoad(view: view!)
        }
    }
}
