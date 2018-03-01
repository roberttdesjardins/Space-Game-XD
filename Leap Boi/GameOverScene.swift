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
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        createGameOverLabel()
        createScoreLabel()
        createRestartButton()
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
        let restartButton = UIButton(frame: CGRect(x: self.size.width/2 - 100, y: self.size.height * (2/3), width: 200, height: 50))
        restartButton.titleLabel?.textAlignment = NSTextAlignment.center
        restartButton.backgroundColor = #colorLiteral(red: 0.7971752948, green: 0.8071641785, blue: 1, alpha: 0.466020976)
        restartButton.setTitleColor(.white, for: .normal)
        restartButton.layer.borderWidth = 5
        restartButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        restartButton.layer.cornerRadius = 10
        restartButton.clipsToBounds = true
        restartButton.setTitle("Tap to Restart", for: .normal)
        restartButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view?.addSubview(restartButton)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        for locView in (self.view?.subviews)! {
            locView.removeFromSuperview()
        }
        resetHealthandScore()
        startSceneLoad(view: view!)
    }
}
